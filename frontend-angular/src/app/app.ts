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
