import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

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

@Component({
  selector: 'app-seguimiento',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './seguimiento.html',
  styleUrl: './seguimiento.css'
})
export class SeguimientoComponent {
  proyectos: ProyectoEnSeguimiento[] = [];
}