import { DatePipe } from '@angular/common';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';

const API_URL = 'https://localhost:7244/api';

interface RecursoRevision {
  id: number;
  nombre: string;
  tipo: string;
  url: string | null;
}

interface EntregaRevision {
  id: number;
  titulo: string;
  tipoTrabajo: string;
  anio: number;
  carrera: string;
  tematica: string;
  resumen: string;
  fechaEnvio: string;
  solicitante: string;
  autores: string[];
  recursos: RecursoRevision[];
}

type DecisionRevision = 'Aprobada' | 'Con correcciones' | 'Rechazada';

@Component({
  selector: 'app-revision-supervisor',
  standalone: true,
  imports: [DatePipe, RouterLink, RouterLinkActive],
  templateUrl: './revision-supervisor.html',
  styleUrl: './revision-supervisor.css'
})
export class RevisionSupervisorComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly cdr = inject(ChangeDetectorRef);

  entregas: EntregaRevision[] = [];
  observaciones: Record<number, string> = {};
  permisosDifusion: Record<number, boolean> = {};
  cargando = true;
  enviandoId: number | null = null;
  mensaje = '';
  mensajeError = '';

  ngOnInit(): void {
    this.cargarPendientes();
  }

  formatearNombre(nombre: string): string {
    return nombre.length === 0
      ? nombre
      : nombre.charAt(0).toLocaleUpperCase('es-SV') + nombre.slice(1);
  }

  actualizarObservacion(id: number, event: Event): void {
    this.observaciones[id] = (event.target as HTMLTextAreaElement).value;
    this.mensajeError = '';
  }

  actualizarPermiso(id: number, event: Event): void {
    this.permisosDifusion[id] = (event.target as HTMLInputElement).checked;
  }

  decidir(entrega: EntregaRevision, decision: DecisionRevision): void {
    const observacion = (this.observaciones[entrega.id] ?? '').trim();

    if (decision !== 'Aprobada' && observacion.length === 0) {
      this.mensajeError =
        'Escribe una observación para pedir correcciones o rechazar.';
      return;
    }

    const token = this.leerToken();
    if (!token) {
      this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.enviandoId = entrega.id;
    this.mensajeError = '';
    this.mensaje = '';

    this.http
      .post<{ mensaje: string }>(
        API_URL + '/revision/' + entrega.id + '/decision',
        {
          decision,
          observacion,
          autorizarDifusion: decision === 'Aprobada' &&
            (this.permisosDifusion[entrega.id] ?? false)
        },
        { headers: { Authorization: 'Bearer ' + token } }
      )
      .subscribe({
        next: respuesta => {
          this.mensaje = respuesta.mensaje;
          this.cdr.markForCheck();
          this.cargarPendientes();
        },
        error: (error: unknown) => {
          this.mensajeError = this.mensajeErrorApi(error);
          this.enviandoId = null;
          this.cdr.markForCheck();
        }
      });
  }

  abrirRecurso(recurso: RecursoRevision): void {
    if (recurso.url) {
      globalThis.open(recurso.url, '_blank', 'noopener,noreferrer');
      return;
    }

    const token = this.leerToken();
    if (!token) {
      this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.http
      .get(API_URL + '/proyectos/recursos/' + recurso.id, {
        headers: { Authorization: 'Bearer ' + token },
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

  private cargarPendientes(): void {
    const token = this.leerToken();
    if (!token) {
      this.cargando = false;
      this.enviandoId = null;
      this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.http
      .get<EntregaRevision[]>(API_URL + '/revision/pendientes', {
        headers: { Authorization: 'Bearer ' + token }
      })
      .subscribe({
        next: datos => {
          this.entregas = datos;
          this.cargando = false;
          this.enviandoId = null;
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          this.cargando = false;
          this.enviandoId = null;
          this.mensajeError = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  private leerToken(): string | null {
    try {
      return globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
    } catch {
      return null;
    }
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

      if (error.status === 401 || error.status === 403) {
        return 'Esta pantalla requiere una sesión con rol de supervisor.';
      }
    }

    return 'No se pudo completar la revisión. Inténtalo de nuevo.';
  }
}
