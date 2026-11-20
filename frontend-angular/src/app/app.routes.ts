import { Routes } from '@angular/router';
import { AuthComponent } from './auth/auth';
import { requireSession, requireSupervisor } from './auth/auth.guard';
import { RevisionSupervisorComponent } from './gestion/revision-supervisor/revision-supervisor';
import { Catalogo } from './catalogo/catalogo';
import { EnvioProyectoComponent } from './publicaciones/envio-proyecto/envio-proyecto';
import { NotificacionesComponent } from './publicaciones/notificacions/notificaciones';
import { SeguimientoComponent } from './publicaciones/seguimiento/seguimiento';

export const routes: Routes = [
  { path: 'iniciar-sesion', component: AuthComponent, data: { mode: 'login' } },
  { path: 'registro', component: AuthComponent, data: { mode: 'registro' } },
  {
    path: 'catalogo',
    component: Catalogo,
    data: {
      active: true,
      works: [],
      areas: [
        'Bases de datos',
        'Desarrollo web',
        'Redes y Comunicación',
        'Inteligencia artificial',
        'Otros'
      ]
    }
  },
  { path: 'publicar', component: EnvioProyectoComponent, canActivate: [requireSession] },
  { path: 'mis-proyectos', component: SeguimientoComponent, canActivate: [requireSession] },
  { path: 'notificaciones', component: NotificacionesComponent, canActivate: [requireSession] },
  { path: 'revision-supervisor', component: RevisionSupervisorComponent, canActivate: [requireSupervisor] },
  { path: '', pathMatch: 'full', redirectTo: 'catalogo' },
  { path: '**', redirectTo: 'catalogo' }
];