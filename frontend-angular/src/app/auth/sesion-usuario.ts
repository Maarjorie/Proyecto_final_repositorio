import { afterNextRender, Component, ElementRef, inject, input } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router, RouterLink } from '@angular/router';
import { filter } from 'rxjs';
import { AUTH_USER_KEY } from './auth.constants';
import { cerrarSesion, sesionActiva, usuarioTieneRol } from './auth.guard';

/** Sesión en el menú: iniciar sesión, o nombre, rol y cerrar sesión. */
@Component({
  selector: 'app-sesion-usuario',
  standalone: true,
  imports: [RouterLink],
  template: `
    @if (activa) {
      @if (esAdministrador && mostrarAdmin()) {
        <a class="enlace-admin" routerLink="/admin">Administración</a>
      }
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

    /* Como los demás enlaces del menú. */
    .enlace-admin {
      display: inline-flex;
      align-items: center;
      min-height: 44px;
      padding: 13px 16px;
      border: 1px solid transparent;
      border-radius: 16px;
      color: #385976;
      font-size: 14px;
      font-weight: 600;
      line-height: 1.2;
      text-decoration: none;
      white-space: nowrap;
      transition: background 0.16s ease, color 0.16s ease, transform 0.16s ease;
    }

    .enlace-admin:hover {
      color: #183653;
      background: rgba(255, 255, 255, 0.6);
      transform: translateY(-1px);
    }

    .enlace-admin:focus-visible {
      outline: 3px solid #68c6dd;
      outline-offset: 2px;
    }

    .boton-sesion:hover {
      transform: translateY(-1px);
      filter: brightness(1.04);
    }

    .boton-sesion:focus-visible {
      outline: 3px solid #68c6dd;
      outline-offset: 2px;
    }

    /* En celular va al final de la fila del menú. */
    @media (max-width: 760px) {
      :host {
        flex: 0 0 auto;
        gap: 6px;
        margin-left: 4px;
        padding-left: 8px;
      }

      .enlace-admin,
      .boton-sesion {
        min-height: 36px;
        padding: 8px 11px;
      }

      .nombre {
        max-width: 120px;
      }
    }
  `
})
export class SesionUsuarioComponent {
  private readonly router = inject(Router);

  readonly activa = sesionActiva();
  readonly nombre: string;
  readonly correo: string;
  /** Oculta el enlace al panel de administración. */
  readonly mostrarAdmin = input(true);

  readonly esAdministrador = usuarioTieneRol('administrador');
  readonly rol = this.esAdministrador
    ? 'Administrador'
    : usuarioTieneRol('supervisor') ? 'Supervisor' : 'Solicitante';

  constructor() {
    let usuario: { nombres?: string; apellidos?: string; correo?: string } = {};
    try {
      usuario = JSON.parse(globalThis.sessionStorage?.getItem(AUTH_USER_KEY) ?? '{}');
    } catch {
      usuario = {};
    }
    this.nombre = [usuario.nombres, usuario.apellidos].filter(Boolean).join(' ') || 'Mi cuenta';
    this.correo = usuario.correo ?? '';

    // En celular el menú se desliza: se muestra el enlace de la página actual
    // cuando el router ya lo marcó como activo.
    const host: ElementRef<HTMLElement> = inject(ElementRef);
    const mostrarActivo = () => setTimeout(() => {
      const menu = host.nativeElement.parentElement;
      const activo = menu?.querySelector<HTMLElement>('a.activo, a.active');
      if (menu && activo && menu.scrollWidth > menu.clientWidth) {
        menu.scrollLeft = activo.offsetLeft - menu.offsetLeft - 12;
      }
    });
    afterNextRender(mostrarActivo);
    this.router.events
      .pipe(filter(evento => evento instanceof NavigationEnd), takeUntilDestroyed())
      .subscribe(mostrarActivo);
  }

  salir(): void {
    cerrarSesion();
    void this.router.navigateByUrl('/iniciar-sesion');
  }
}
