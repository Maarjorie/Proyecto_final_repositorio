import { Component, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { AUTH_USER_KEY } from './auth.constants';
import { cerrarSesion, sesionActiva, usuarioTieneRol } from './auth.guard';

/**
 * Parte derecha del menú: "Iniciar sesión" sin sesión, o el nombre de la
 * cuenta con su rol y "Cerrar sesión" con sesión. Se usa en todas las pantallas.
 */
@Component({
  selector: 'app-sesion-usuario',
  standalone: true,
  imports: [RouterLink],
  template: `
    @if (activa) {
      <span class="cuenta" [title]="correo">
        <span class="nombre">{{ nombre }}</span>
        <span class="rol">{{ rol }}</span>
      </span>
      <button type="button" class="boton-sesion" (click)="salir()">Cerrar sesión</button>
    } @else {
      <a class="boton-sesion" routerLink="/iniciar-sesion">Iniciar sesión</a>
    }
  `,
  styles: `
    :host {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      margin-left: 6px;
      padding-left: 12px;
      border-left: 1px solid rgba(12, 57, 111, 0.18);
    }

    .cuenta {
      display: grid;
      line-height: 1.15;
      text-align: right;
    }

    .nombre {
      max-width: 160px;
      overflow: hidden;
      color: #183653;
      font-size: 13px;
      font-weight: 800;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .rol {
      color: #526f88;
      font-size: 11px;
      font-weight: 700;
    }

    .boton-sesion {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-height: 40px;
      padding: 10px 14px;
      border: 1px solid rgba(255, 255, 255, 0.65);
      border-radius: 14px;
      background: linear-gradient(145deg, rgba(255, 255, 255, 0.95), rgba(205, 233, 240, 0.9));
      color: #183653;
      font: inherit;
      font-size: 13px;
      font-weight: 800;
      line-height: 1.2;
      text-decoration: none;
      white-space: nowrap;
      cursor: pointer;
      box-shadow: 0 6px 14px rgba(5, 27, 54, 0.16), inset 0 1px 3px #fff;
      transition: transform 160ms ease, filter 160ms ease;
    }

    .boton-sesion:hover {
      transform: translateY(-1px);
      filter: brightness(1.04);
    }

    .boton-sesion:focus-visible {
      outline: 3px solid #68c6dd;
      outline-offset: 2px;
    }

    @media (max-width: 760px) {
      :host {
        width: 100%;
        justify-content: space-between;
        margin: 6px 0 0;
        padding: 10px 0 0;
        border-left: 0;
        border-top: 1px solid rgba(12, 57, 111, 0.18);
      }

      .cuenta {
        text-align: left;
      }
    }
  `
})
export class SesionUsuarioComponent {
  private readonly router = inject(Router);

  readonly activa = sesionActiva();
  readonly nombre: string;
  readonly correo: string;
  readonly rol = usuarioTieneRol('supervisor') ? 'Supervisor' : 'Solicitante';

  constructor() {
    let usuario: { nombres?: string; apellidos?: string; correo?: string } = {};
    try {
      usuario = JSON.parse(globalThis.sessionStorage?.getItem(AUTH_USER_KEY) ?? '{}');
    } catch {
      usuario = {};
    }
    this.nombre = [usuario.nombres, usuario.apellidos].filter(Boolean).join(' ') || 'Mi cuenta';
    this.correo = usuario.correo ?? '';
  }

  salir(): void {
    cerrarSesion();
    void this.router.navigateByUrl('/iniciar-sesion');
  }
}
