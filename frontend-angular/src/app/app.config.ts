import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter, withComponentInputBinding, withViewTransitions } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideHttpClient(),
    // Transición suave entre pantallas (los estilos están en styles.css).
    provideRouter(routes, withComponentInputBinding(), withViewTransitions({ skipInitialTransition: true }))
  ]
};
