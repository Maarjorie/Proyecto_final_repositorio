import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

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
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './notificaciones.html',
  styleUrl: './notificaciones.css'
})
export class NotificacionesComponent {
  notificaciones: Notificacion[] = [];
}
