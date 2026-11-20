import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AUTH_EXPIRY_KEY, AUTH_TOKEN_KEY, AUTH_USER_KEY } from './auth.constants';

/** Borra la sesión guardada en este navegador (token, vencimiento y usuario). */
export function cerrarSesion(): void {
  try {
    globalThis.sessionStorage?.removeItem(AUTH_TOKEN_KEY);
    globalThis.sessionStorage?.removeItem(AUTH_EXPIRY_KEY);
    globalThis.sessionStorage?.removeItem(AUTH_USER_KEY);
  } catch {
    // Sin acceso al almacenamiento no hay sesión que borrar.
  }
}

export function sesionActiva(): boolean {
  try {
    const token = globalThis.sessionStorage?.getItem(AUTH_TOKEN_KEY);
    const expiry = globalThis.sessionStorage?.getItem(AUTH_EXPIRY_KEY);
    if (token && expiry && Date.parse(expiry) > Date.now()) {
      return true;
    }

    globalThis.sessionStorage?.removeItem(AUTH_TOKEN_KEY);
    globalThis.sessionStorage?.removeItem(AUTH_EXPIRY_KEY);
  } catch {
    // Si el navegador bloquea el almacenamiento, se solicita iniciar sesión.
  }

  return false;
}

export function usuarioTieneRol(rolEsperado: string): boolean {
  try {
    const token = globalThis.sessionStorage?.getItem(AUTH_TOKEN_KEY);
    const payloadCodificado = token?.split('.')[1];
    if (!payloadCodificado) {
      return false;
    }

    let base64 = payloadCodificado.replace(/-/g, '+').replace(/_/g, '/');
    base64 = base64.padEnd(Math.ceil(base64.length / 4) * 4, '=');
    const claims = JSON.parse(globalThis.atob(base64)) as Record<string, unknown>;
    const roles = Object.entries(claims)
      .filter(([nombre]) => {
        const clave = nombre.toLowerCase();
        return clave === 'role' || clave === 'roles' || clave.endsWith('/role');
      })
      .flatMap(([, valor]) => Array.isArray(valor) ? valor : [valor])
      .filter((valor): valor is string => typeof valor === 'string');

    return roles.some(rol => rol.toLowerCase() === rolEsperado.toLowerCase());
  } catch {
    return false;
  }
}

export const requireSession: CanActivateFn = (_route, state) => {
  const router = inject(Router);

  if (sesionActiva()) {
    return true;
  }

  return router.createUrlTree(['/iniciar-sesion'], {
    queryParams: { returnUrl: state.url }
  });
};

/**
 * Pantallas del solicitante (enviar y seguir proyectos). RNF-03: "el
 * solicitante envía, el supervisor decide"; una cuenta de supervisor usa
 * su propia interfaz y se redirige a la revisión.
 */
export const requireSolicitante: CanActivateFn = (_route, state) => {
  const router = inject(Router);

  if (!sesionActiva()) {
    return router.createUrlTree(['/iniciar-sesion'], {
      queryParams: { returnUrl: state.url }
    });
  }

  return usuarioTieneRol('supervisor')
    ? router.createUrlTree(['/revision-supervisor'])
    : true;
};

export const requireSupervisor: CanActivateFn = (_route, state) => {
  const router = inject(Router);

  if (!sesionActiva()) {
    return router.createUrlTree(['/iniciar-sesion'], {
      queryParams: { returnUrl: state.url }
    });
  }

  return usuarioTieneRol('supervisor')
    ? true
    : router.createUrlTree(['/catalogo']);
};
