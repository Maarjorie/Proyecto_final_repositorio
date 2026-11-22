import { Routes } from '@angular/router';
import { AuthComponent } from './auth/auth';
import { requireAdministrador, requireSession, requireSolicitante, requireSupervisor } from './auth/auth.guard';
import { RevisionSupervisorComponent } from './gestion/revision-supervisor/revision-supervisor';
import { Catalogo } from './catalogo/catalogo';
import { EnvioProyectoComponent } from './publicaciones/envio-proyecto/envio-proyecto';
import { NotificacionesComponent } from './publicaciones/notificacions/notificaciones';
import { SeguimientoComponent } from './publicaciones/seguimiento/seguimiento';
import { AdminPanel } from './gestion/administrador/admin-panel';
import { EstadisticasComponent } from './gestion/estadisticas/estadisticas';

export const routes: Routes = [
  { path: 'iniciar-sesion', component: AuthComponent, data: { mode: 'login' } },
  { path: 'registro', component: AuthComponent, data: { mode: 'registro' } },
  // Panel de administración: solo el rol administrador (RNF-03).
  { path: 'admin', pathMatch: 'full', redirectTo: 'admin/cuentas' },
  { path: 'admin/:seccion', component: AdminPanel, canActivate: [requireAdministrador] },
  {
    path: 'catalogo',
    component: Catalogo,
    // Las fichas y las áreas se cargan desde la API dentro del componente.
    data: { active: true }
  },
  // Solo el solicitante envía y sigue proyectos; el supervisor revisa (RNF-03).
  { path: 'publicar', component: EnvioProyectoComponent, canActivate: [requireSolicitante] },
  { path: 'mis-proyectos', component: SeguimientoComponent, canActivate: [requireSolicitante] },
  { path: 'notificaciones', component: NotificacionesComponent, canActivate: [requireSession] },
  { path: 'revision-supervisor', component: RevisionSupervisorComponent, canActivate: [requireSupervisor] },
  // RF-12: conteo de proyectos por año y área.
  { path: 'estadisticas', component: EstadisticasComponent, canActivate: [requireSupervisor] },
  { path: '', pathMatch: 'full', redirectTo: 'catalogo' },
  { path: '**', redirectTo: 'catalogo' }
];