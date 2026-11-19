import { Component } from '@angular/core';

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

export interface NotificacionUsuario {
  id: number;
  proyectoId: number;
  mensaje: string;
  fecha: string;
  leida: boolean;
}

@Component({
  selector: 'app-seguimiento',
  standalone: true,
  templateUrl: './seguimiento.html',
  styleUrl: './seguimiento.css'
})
export class SeguimientoComponent {
  proyectos: ProyectoEnSeguimiento[] = [];
  notificaciones: NotificacionUsuario[] = [];
}