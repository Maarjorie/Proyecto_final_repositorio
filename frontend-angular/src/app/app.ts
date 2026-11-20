import { Component } from '@angular/core';
import { EnvioProyectoComponent } from './publicaciones/envio-proyecto/envio-proyecto';
@Component({
  selector: 'app-root',
  standalone: true,
 imports: [EnvioProyectoComponent],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {}
export interface Work {
  id: number;
  title: string;
  authors: string[];
  year: number;
  type: string;
  career: string;
  subject: string;
  area: string;
  summary: string;
  keywords: string[];
  published: boolean;
  permission: string;
  approvedResourceIds: number[];

}
