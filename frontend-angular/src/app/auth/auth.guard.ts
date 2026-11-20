import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AUTH_EXPIRY_KEY, AUTH_TOKEN_KEY } from './auth.constants';

export const requireSession: CanActivateFn = (_route, state) => {
  const router = inject(Router);

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

  return router.createUrlTree(['/iniciar-sesion'], {
    queryParams: { returnUrl: state.url }
  });
};