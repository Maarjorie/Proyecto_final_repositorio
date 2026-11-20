import { usuarioTieneRol } from '../../auth/auth.guard';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';

const API_URL = 'https://localhost:7244/api';

export type EstadoSolicitud =
  | 'Pendiente'
  | 'Con correcciones'
  | 'Aprobada'
  | 'Rechazada';

export interface ProyectoEnSeguimiento {
  id: number;
  titulo: string;
  tipoTrabajo: string;
  fechaEnvio: string;
  version: number;
  estado: EstadoSolicitud;
  observacion: string | null;
}

@Component({
  selector: 'app-seguimiento',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './seguimiento.html',
  styleUrl: './seguimiento.css'
})
export class SeguimientoComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly cdr = inject(ChangeDetectorRef);

  proyectos: ProyectoEnSeguimiento[] = [];
  cargando = true;
  mensajeError = '';
  readonly esSupervisor = usuarioTieneRol('supervisor');

  ngOnInit(): void {
    let token: string | null = null;

    try {
      token = globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
    } catch {
      this.cargando = false;
      this.mensajeError = 'No se pudo leer la sesión. Inicia sesión de nuevo.';
      return;
    }

    if (!token) {
      this.cargando = false;
      this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.http
      .get<ProyectoEnSeguimiento[]>(API_URL + '/proyectos/mis-proyectos', {
        headers: { Authorization: 'Bearer ' + token }
      })
      .subscribe({
        next: datos => {
          this.proyectos = datos;
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
    }

    return 'No se pudieron cargar tus proyectos. Inténtalo de nuevo.';
  }
}
