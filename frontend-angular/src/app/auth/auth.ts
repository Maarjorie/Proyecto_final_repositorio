import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, input } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AUTH_API_URL, AUTH_EXPIRY_KEY, AUTH_TOKEN_KEY, AUTH_USER_KEY } from './auth.constants';

type AuthMode = 'login' | 'registro';

interface AuthResponse {
  token: string;
  expiraUtc: string;
  usuario: {
    id: number;
    nombres: string;
    apellidos: string;
    correo: string;
    roles?: string[];
  };
}

@Component({
  selector: 'app-auth',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './auth.html',
  styleUrl: './auth.css'
})
export class AuthComponent {
  readonly mode = input<AuthMode>('login');

  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly cdr = inject(ChangeDetectorRef);

  nombres = '';
  apellidos = '';
  correo = '';
  contrasena = '';
  confirmarContrasena = '';
  enviando = false;
  mensajeError = '';

  get returnUrl(): string {
    const requested = this.route.snapshot.queryParamMap.get('returnUrl');
    return requested?.startsWith('/') && !requested.startsWith('//')
      ? requested
      : '/catalogo';
  }

  /**
   * Si la persona venía de una página protegida, vuelve a ella. Si no, entra a
   * la pantalla de su rol: el supervisor a la revisión (RF-21) y el
   * solicitante a sus proyectos (RF-19).
   */
  private destinoTrasIngresar(roles: string[]): string {
    if (this.route.snapshot.queryParamMap.has('returnUrl') && this.returnUrl !== '/catalogo') {
      const pideRevision = this.returnUrl.startsWith('/revision-supervisor');
      if (!pideRevision || roles.includes('supervisor')) {
        return this.returnUrl;
      }
    }

    // El administrador entra a su panel; si además es supervisor, puede ir a la revisión desde el menú.
    if (roles.includes('administrador')) {
      return '/admin';
    }

    if (roles.includes('supervisor')) {
      return '/revision-supervisor';
    }

    return '/mis-proyectos';
  }

  get queryParams(): Record<string, string> | null {
    return this.returnUrl === '/catalogo'
      ? null
      : { returnUrl: this.returnUrl };
  }

  async submit(): Promise<void> {
    if (this.enviando) return;

    const mode = this.mode();
    this.mensajeError = '';

    if (mode === 'registro' && this.contrasena !== this.confirmarContrasena) {
      this.mensajeError = 'Las contraseñas no coinciden.';
      return;
    }

    const endpoint = mode === 'login' ? 'login' : 'registro';
    const payload = mode === 'login'
      ? {
          correo: this.correo.trim(),
          contrasena: this.contrasena
        }
      : {
          nombres: this.nombres.trim(),
          apellidos: this.apellidos.trim(),
          correo: this.correo.trim(),
          contrasena: this.contrasena
        };

    this.enviando = true;

    try {
      const response = await firstValueFrom(
        this.http.post<AuthResponse>(AUTH_API_URL + '/' + endpoint, payload)
      );

      try {
        globalThis.sessionStorage.setItem(AUTH_TOKEN_KEY, response.token);
        globalThis.sessionStorage.setItem(AUTH_EXPIRY_KEY, response.expiraUtc);
        globalThis.sessionStorage.setItem(AUTH_USER_KEY, JSON.stringify(response.usuario));
      } catch {
        this.mensajeError = 'El navegador no permitió guardar la sesión. Habilita el almacenamiento y vuelve a intentarlo.';
        return;
      }

      await this.router.navigateByUrl(this.destinoTrasIngresar(response.usuario.roles ?? []));
    } catch (error: unknown) {
      this.mensajeError = this.getErrorMessage(error);
    } finally {
      this.enviando = false;
      this.cdr.markForCheck();
    }
  }

  private getErrorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      const apiMessage = error.error && typeof error.error.mensaje === 'string'
        ? error.error.mensaje
        : null;

      if (apiMessage) return apiMessage;
      if (error.status === 0) {
        return 'No se pudo conectar con el servidor. Verifica que RepositorioApi esté iniciado en https://localhost:7244.';
      }
    }

    return 'No se pudo completar la solicitud. Revisa los datos e inténtalo de nuevo.';
  }
}