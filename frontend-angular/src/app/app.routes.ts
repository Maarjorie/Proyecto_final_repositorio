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
  // Administración: solo administradores.
  { path: 'admin', pathMatch: 'full', redirectTo: 'admin/cuentas' },
  { path: 'admin/:seccion', component: AdminPanel, canActivate: [requireAdministrador] },
  {
    path: 'catalogo',
    component: Catalogo,
    data: { active: true }
  },
  // Pantallas del solicitante.
  { path: 'publicar', component: EnvioProyectoComponent, canActivate: [requireSolicitante] },
  { path: 'mis-proyectos', component: SeguimientoComponent, canActivate: [requireSolicitante] },
  { path: 'notificaciones', component: NotificacionesComponent, canActivate: [requireSession] },
  { path: 'revision-supervisor', component: RevisionSupervisorComponent, canActivate: [requireSupervisor] },
  // Estadísticas por año y área (RF-12).
  { path: 'estadisticas', component: EstadisticasComponent, canActivate: [requireSupervisor] },
  { path: '', pathMatch: 'full', redirectTo: 'catalogo' },
  { path: '**', redirectTo: 'catalogo' }
];