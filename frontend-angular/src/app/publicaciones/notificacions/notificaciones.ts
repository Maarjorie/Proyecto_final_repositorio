import { SesionUsuarioComponent } from '../../auth/sesion-usuario';
import { esCuentaDeGestion, usuarioTieneRol } from '../../auth/auth.guard';
import { DatePipe } from '@angular/common';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';

const API_URL = 'https://localhost:7244/api';

export type TipoNotificacion =
  | 'Nueva entrega'
  | 'Correcciones solicitadas'
  | 'Proyecto aprobado'
  | 'Proyecto rechazado'
  | 'Publicación retirada'
  | 'Aviso';

export interface Notificacion {
  id: number;
  idEntrega: number;
  tituloProyecto: string;
  tipo: TipoNotificacion;
  mensaje: string;
  fecha: string;
  leida: boolean;
}

@Component({
  selector: 'app-notificaciones',
  standalone: true,
  imports: [SesionUsuarioComponent, DatePipe, RouterLink, RouterLinkActive],
  templateUrl: './notificaciones.html',
  styleUrl: './notificaciones.css'
})
export class NotificacionesComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  // La app es zoneless: tras cada respuesta HTTP hay que pedir que se repinte.
  private readonly cdr = inject(ChangeDetectorRef);

  readonly esSupervisor = usuarioTieneRol('supervisor');
  readonly esGestion = esCuentaDeGestion();
  notificaciones: Notificacion[] = [];
  cargando = true;
  mensajeError = '';

  get sinLeer(): number {
    return this.notificaciones.filter(notificacion => !notificacion.leida).length;
  }

  ngOnInit(): void {
    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      this.cargando = false;
      return;
    }

    this.http
      .get<Notificacion[]>(API_URL + '/notificaciones', { headers: cabeceras })
      .subscribe({
        next: datos => {
          this.notificaciones = datos;
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

  /** Las fechas llegan en UTC sin zona; se marcan como UTC para mostrarlas en hora local. */
  fechaLocal(fecha: string): Date {
    const tieneZona = /[zZ]|[+-]\d{2}:?\d{2}$/.test(fecha);
    return new Date(tieneZona ? fecha : fecha + 'Z');
  }

  textoAccion(notificacion: Notificacion): string {
    return this.esSupervisor ? 'Ir a revisión' : 'Ver mi solicitud';
  }

  /** Marca el aviso como leído y lleva a la pantalla donde se atiende. */
  abrir(notificacion: Notificacion): void {
    this.marcarLeida(notificacion);
    // Cada rol atiende sus avisos en su propia pantalla.
    const destino = this.esSupervisor ? '/revision-supervisor' : '/mis-proyectos';
    void this.router.navigateByUrl(destino);
  }

  marcarLeida(notificacion: Notificacion): void {
    if (notificacion.leida) {
      return;
    }
    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      return;
    }

    notificacion.leida = true;
    this.http
      .post(API_URL + '/notificaciones/' + notificacion.id + '/leida', null, { headers: cabeceras })
      .subscribe({
        error: () => {
          notificacion.leida = false;
          this.cdr.markForCheck();
        }
      });
  }

  marcarTodasLeidas(): void {
    const cabeceras = this.cabeceras();
    if (!cabeceras) {
      return;
    }

    const pendientes = this.notificaciones.filter(notificacion => !notificacion.leida);
    pendientes.forEach(notificacion => notificacion.leida = true);
    this.http
      .post(API_URL + '/notificaciones/leidas', null, { headers: cabeceras })
      .subscribe({
        error: (error: unknown) => {
          pendientes.forEach(notificacion => notificacion.leida = false);
          this.mensajeError = this.mensajeErrorApi(error);
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

  private mensajeErrorApi(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      if (error.status === 0) {
        return 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.';
      }
      if (error.status === 401) {
        return 'Tu sesión venció. Inicia sesión de nuevo.';
      }
    }
    return 'No se pudieron cargar tus notificaciones. Inténtalo de nuevo.';
  }
}
