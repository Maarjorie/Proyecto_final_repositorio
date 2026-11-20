import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';


type PermissionMode =
  | 'Pendiente'
  | 'Solo ficha'
  | 'Ficha y materiales autorizados';

type ResourceKind = 'PDF' | 'ZIP' | 'Enlace de descarga' | 'Demostración';

interface Resource {
  id: number;
  name: string;
  kind: ResourceKind;
  href: string;
}

export interface Work {
  id: number;
  title: string;
  authors: string[];
  year: number;
  career: string;
  area: string;
  type: string;
  subject: string;
  summary: string;
  keywords: string[];
  advisor: string;
  advisorAllowed: boolean;
  permission: PermissionMode;
  approvedResourceIds: number[];
  resources: Resource[];
  published: boolean;
  featured: boolean;
  withdrawnReason: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {}
