import { SesionUsuarioComponent } from '../../auth/sesion-usuario';
import { DatePipe } from '@angular/common';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { Observable } from 'rxjs';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';

const API_URL = 'https://localhost:7244/api';

interface RecursoRevision {
  id: number;
  nombre: string;
  tipo: string;
  url: string | null;
  autorizado: boolean;
}

interface EntregaRevision {
  id: number;
  idProyecto: number;
  titulo: string;
  tipoTrabajo: string;
  anio: number;
  departamento: string;
  carrera: string;
  tematica: string;
  resumen: string;
  palabrasClave: string[];
  fechaEnvio: string;
  version: number;
  solicitante: string;
  autores: string[];
  recursos: RecursoRevision[];
}

/** RF-10: lo que los autores permiten difundir. */
type Permiso = 'pendiente' | 'solo_ficha' | 'ficha_y_materiales' | 'no_autorizado';

interface Publicacion {
  idProyecto: number;
  idEntrega: number;
  titulo: string;
  tipoTrabajo: string;
  anio: number;
  carrera: string;
  autores: string[];
  fechaAprobacion: string;
  revisor: string | null;
  permiso: Permiso;
  estadoPublicacion: 'publicado' | 'no_publicado' | 'retirado';
  destacado: boolean;
  motivoRetiro: string | null;
  fechaRetiro: string | null;
  recursos: RecursoRevision[];
}

type DecisionRevision = 'Aprobada' | 'Con correcciones' | 'Rechazada';
type Pestana = 'pendientes' | 'publicaciones';

/** Borrador del permiso que se edita en una tarjeta antes de guardarlo. */
interface BorradorPermiso {
  permiso: Permiso;
  recursos: number[];
}

@Component({
  selector: 'app-revision-supervisor',
  standalone: true,
  imports: [SesionUsuarioComponent, DatePipe, RouterLink, RouterLinkActive],
  templateUrl: './revision-supervisor.html',
  styleUrls: [
    '../../publicaciones/seguimiento/seguimiento.css',
    './revision-supervisor.css'
  ]
})
export class RevisionSupervisorComponent implements OnInit {
  private readonly http = inject(HttpClient);
  // La app es zoneless: tras cada respuesta HTTP hay que pedir que se repinte.
  private readonly cdr = inject(ChangeDetectorRef);

  readonly opcionesPermiso: { valor: Permiso; texto: string; ayuda: string }[] = [
    { valor: 'pendiente', texto: 'Permiso pendiente', ayuda: 'Se aprueba, pero no se publica hasta registrar el permiso.' },
    { valor: 'solo_ficha', texto: 'Solo la ficha', ayuda: 'Se publican los datos; los materiales quedan reservados.' },
    { valor: 'ficha_y_materiales', texto: 'Ficha y materiales seleccionados', ayuda: 'Se publican los datos y los materiales marcados.' },
    { valor: 'no_autorizado', texto: 'No autorizan la difusión', ayuda: 'Queda aprobado, pero no se publica.' }
  ];

  pestana: Pestana = 'pendientes';

  entregas: EntregaRevision[] = [];
  publicaciones: Publicacion[] = [];
  cargando = true;
  cargandoPublicaciones = false;
  publicacionesCargadas = false;

  observaciones: Record<number, string> = {};
  permisosDecision: Record<number, BorradorPermiso> = {};
  permisosPublicacion: Record<number, BorradorPermiso> = {};
  motivosRetiro: Record<number, string> = {};
  retirandoId: number | null = null;

  ocupadoId: number | null = null;
  /** Tarjeta donde se muestra el último error, para verlo junto al botón. */
  errorEntregaId: number | null = null;
  mensaje = '';
  mensajeError = '';

  ngOnInit(): void {
    this.cargarPendientes();
  }

  // ----- Utilidades de presentación -----

  formatearNombre(nombre: string): string {
    return nombre.length === 0
      ? nombre
      : nombre.charAt(0).toLocaleUpperCase('es-SV') + nombre.slice(1);
  }

  /** Las fechas llegan en UTC sin zona; se marcan como UTC para mostrarlas en hora local. */
  fechaLocal(fecha: string | null): Date | null {
    if (!fecha) {
      return null;
    }
    const tieneZona = /[zZ]|[+-]\d{2}:?\d{2}$/.test(fecha);
    return new Date(tieneZona ? fecha : fecha + 'Z');
  }

  textoPermiso(permiso: Permiso): string {
    return this.opcionesPermiso.find(opcion => opcion.valor === permiso)?.texto ?? permiso;
  }

  textoPublicacion(estado: Publicacion['estadoPublicacion']): string {
    return estado === 'publicado'
      ? 'Publicado'
      : estado === 'retirado'
        ? 'Retirado'
        : 'Sin publicar';
  }

  cambiarPestana(pestana: Pestana): void {
    this.pestana = pestana;
    this.limpiarMensajes();
    if (pestana === 'publicaciones' && !this.publicacionesCargadas) {
      this.cargarPublicaciones();
    }
  }

  // ----- Pendientes (RF-18, RF-21) -----

  borradorDecision(entrega: EntregaRevision): BorradorPermiso {
    return this.permisosDecision[entrega.id] ??= { permiso: 'pendiente', recursos: [] };
  }

  actualizarObservacion(id: number, event: Event): void {
    this.observaciones[id] = (event.target as HTMLTextAreaElement).value;
    this.mensajeError = '';
  }

  elegirPermiso(borrador: BorradorPermiso, permiso: Permiso): void {
    borrador.permiso = permiso;
    if (permiso !== 'ficha_y_materiales') {
      borrador.recursos = [];
    }
    this.mensajeError = '';
  }

  alternarRecurso(borrador: BorradorPermiso, idRecurso: number, event: Event): void {
    const marcado = (event.target as HTMLInputElement).checked;
    borrador.recursos = marcado
      ? [...borrador.recursos, idRecurso]
      : borrador.recursos.filter(id => id !== idRecurso);
  }

  decidir(entrega: EntregaRevision, decision: DecisionRevision): void {
    const observacion = (this.observaciones[entrega.id] ?? '').trim();
    const borrador = this.borradorDecision(entrega);
    this.errorEntregaId = entrega.id;

    if (decision === 'Rechazada' && observacion.length === 0) {
      this.mensajeError = 'Escribe el motivo del rechazo.';
      return;
    }

    if (decision === 'Con correcciones' && observacion.length === 0) {
      this.mensajeError = 'Describe las correcciones que debe hacer el solicitante.';
      return;
    }

    if (decision === 'Aprobada' &&
        borrador.permiso === 'ficha_y_materiales' &&
        borrador.recursos.length === 0) {
      this.mensajeError = 'Marca al menos un material autorizado o elige «Solo la ficha».';
      return;
    }

    const cuerpo = {
      decision,
      observacion,
      permiso: decision === 'Aprobada' ? borrador.permiso : null,
      recursosAutorizados: decision === 'Aprobada' ? borrador.recursos : []
    };

    this.ejecutar(
      entrega.id,
      this.http.post<{ mensaje: string }>(
        API_URL + '/revision/' + entrega.id + '/decision',
        cuerpo,
        { headers: this.cabeceras() ?? {} }
      ),
      respuesta => {
        this.mensaje = respuesta.mensaje;
        this.entregas = this.entregas.filter(item => item.id !== entrega.id);
        delete this.observaciones[entrega.id];
        delete this.permisosDecision[entrega.id];
        // La lista de publicaciones cambia al aprobar.
        this.publicacionesCargadas = false;
      },
      error => {
        // Si otro supervisor ya decidió, se recarga para mostrar lo vigente.
        if (error instanceof HttpErrorResponse && error.status === 409) {
          this.cargarPendientes();
        }
      }
    );
  }

  // ----- Publicaciones (RF-07, RF-09, RF-10, RF-12) -----

  borradorPublicacion(publicacion: Publicacion): BorradorPermiso {
    return this.permisosPublicacion[publicacion.idProyecto] ??= {
      permiso: publicacion.permiso,
      recursos: publicacion.recursos.filter(recurso => recurso.autorizado).map(recurso => recurso.id)
    };
  }

  permisoCambio(publicacion: Publicacion): boolean {
    const borrador = this.borradorPublicacion(publicacion);
    const actuales = publicacion.recursos
      .filter(recurso => recurso.autorizado)
      .map(recurso => recurso.id)
      .sort((a, b) => a - b)
      .join(',');
    return borrador.permiso !== publicacion.permiso ||
      [...borrador.recursos].sort((a, b) => a - b).join(',') !== actuales;
  }

  guardarPermiso(publicacion: Publicacion): void {
    const borrador = this.borradorPublicacion(publicacion);
    if (borrador.permiso === 'ficha_y_materiales' && borrador.recursos.length === 0) {
      this.mensajeError = 'Marca al menos un material autorizado o elige «Solo la ficha».';
      return;
    }

    this.ejecutar(
      publicacion.idProyecto,
      this.http.put<{ mensaje: string }>(
        API_URL + '/revision/proyectos/' + publicacion.idProyecto + '/permiso',
        { permiso: borrador.permiso, recursosAutorizados: borrador.recursos },
        { headers: this.cabeceras() ?? {} }
      ),
      respuesta => {
        this.mensaje = respuesta.mensaje;
        this.cargarPublicaciones();
      }
    );
  }

  alternarDestacado(publicacion: Publicacion): void {
    this.ejecutar(
      publicacion.idProyecto,
      this.http.put<{ mensaje: string; destacado: boolean }>(
        API_URL + '/revision/proyectos/' + publicacion.idProyecto + '/destacado',
        { destacado: !publicacion.destacado },
        { headers: this.cabeceras() ?? {} }
      ),
      respuesta => {
        this.mensaje = respuesta.mensaje;
        publicacion.destacado = respuesta.destacado;
      }
    );
  }

  iniciarRetiro(publicacion: Publicacion): void {
    this.retirandoId = publicacion.idProyecto;
    this.motivosRetiro[publicacion.idProyecto] ??= '';
    this.limpiarMensajes();
  }

  cancelarRetiro(): void {
    this.retirandoId = null;
  }

  actualizarMotivo(idProyecto: number, event: Event): void {
    this.motivosRetiro[idProyecto] = (event.target as HTMLTextAreaElement).value;
    this.mensajeError = '';
  }

  confirmarRetiro(publicacion: Publicacion): void {
    const motivo = (this.motivosRetiro[publicacion.idProyecto] ?? '').trim();
    if (motivo.length === 0) {
      this.mensajeError = 'Escribe el motivo del retiro. Sin motivo no se confirma.';
      return;
    }

    this.ejecutar(
      publicacion.idProyecto,
      this.http.post<{ mensaje: string }>(
        API_URL + '/revision/proyectos/' + publicacion.idProyecto + '/retirar',
        { motivo },
        { headers: this.cabeceras() ?? {} }
      ),
      respuesta => {
        this.mensaje = respuesta.mensaje;
        this.retirandoId = null;
        delete this.motivosRetiro[publicacion.idProyecto];
        this.cargarPublicaciones();
      }
    );
  }

  // ----- Materiales -----

  abrirRecurso(recurso: RecursoRevision): void {
    if (recurso.url) {
      globalThis.open(recurso.url, '_blank', 'noopener,noreferrer');
      return;
    }

    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      return;
    }

    this.http
      .get(API_URL + '/proyectos/recursos/' + recurso.id, {
        headers: cabeceras,
        responseType: 'blob'
      })
      .subscribe({
        next: archivo => {
          const url = URL.createObjectURL(archivo);
          const enlace = document.createElement('a');
          enlace.href = url;
          enlace.download = recurso.nombre;
          enlace.click();
          URL.revokeObjectURL(url);
        },
        error: (error: unknown) => {
          this.mensajeError = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  // ----- Carga de datos -----

  private cargarPendientes(): void {
    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      this.cargando = false;
      return;
    }

    this.cargando = true;
    this.http
      .get<EntregaRevision[]>(API_URL + '/revision/pendientes', { headers: cabeceras })
      .subscribe({
        next: datos => {
          this.entregas = datos;
          this.cargando = false;
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          this.cargando = false;
          this.mensajeError = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  private cargarPublicaciones(): void {
    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      return;
    }

    this.cargandoPublicaciones = true;
    this.http
      .get<Publicacion[]>(API_URL + '/revision/publicaciones', { headers: cabeceras })
      .subscribe({
        next: datos => {
          this.publicaciones = datos;
          // Los borradores se recalculan con los datos guardados.
          this.permisosPublicacion = {};
          this.cargandoPublicaciones = false;
          this.publicacionesCargadas = true;
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          this.cargandoPublicaciones = false;
          this.mensajeError = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  /** Ejecuta una acción del supervisor, bloqueando la tarjeta mientras responde. */
  private ejecutar<T>(
    id: number,
    peticion$: Observable<T>,
    alTerminar: (respuesta: T) => void,
    alFallar?: (error: unknown) => void
  ): void {
    this.ocupadoId = id;
    this.limpiarMensajes();

    peticion$.subscribe({
      next: respuesta => {
        this.ocupadoId = null;
        alTerminar(respuesta);
        this.cdr.markForCheck();
      },
      error: (error: unknown) => {
        this.ocupadoId = null;
        this.mensajeError = this.mensajeErrorApi(error);
        alFallar?.(error);
        this.cdr.markForCheck();
      }
    });
  }

  private cabeceras(): Record<string, string> | null {
    try {
      const token = globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
      if (token) {
        return { Authorization: 'Bearer ' + token };
      }
    } catch {
      // Sin acceso al almacenamiento no hay sesión.
    }

    this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
    return null;
  }

  private limpiarMensajes(): void {
    this.mensaje = '';
    this.mensajeError = '';
  }

  private mensajeErrorApi(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      const mensajeApi =
        error.error && typeof error.error.mensaje === 'string'
          ? error.error.mensaje
          : null;

      if (mensajeApi) {
        return mensajeApi;
      }
      if (error.status === 0) {
        return 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.';
      }
      if (error.status === 401) {
        return 'Tu sesión venció. Inicia sesión de nuevo.';
      }
      if (error.status === 403) {
        return 'Tu cuenta no tiene el rol de supervisor.';
      }
    }

    return 'No se pudo completar la acción. Inténtalo de nuevo.';
  }
}
