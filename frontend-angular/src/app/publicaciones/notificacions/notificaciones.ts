import { Component } from '@angular/core';

export type TipoNotificacion =
  | 'Correcciones solicitadas'
  | 'Proyecto aprobado'
  | 'Proyecto rechazado';

export interface Notificacion {
  id: number;
  tituloProyecto: string;
  tipo: TipoNotificacion;
  mensaje: string;
  fecha: string;
  leida: boolean;
}

@Component({
  selector: 'app-notificaciones',
  standalone: true,
  templateUrl: './notificaciones.html',
  styleUrl: './notificaciones.css'
})
export class NotificacionesComponent {
  notificaciones: Notificacion[] = [];
}
