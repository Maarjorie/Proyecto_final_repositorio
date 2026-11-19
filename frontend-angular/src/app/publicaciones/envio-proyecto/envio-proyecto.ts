import { Component } from '@angular/core';

interface AutorFormulario {
  nombres: string;
  apellidos: string;
  carnet: string;
}

interface OpcionCatalogo {
  id: number;
  nombre: string;
}

@Component({
  selector: 'app-envio-proyecto',
  standalone: true,
  templateUrl: './envio-proyecto.html',
  styleUrl: './envio-proyecto.css'
})
export class EnvioProyectoComponent {
  autores: AutorFormulario[] = [
    { nombres: '', apellidos: '', carnet: '' }
  ];

  pdfs: File[] = [];
  archivosZip: File[] = [];
  enlaces: string[] = [];
  palabrasClave: string[] = [];
  mensajeError = '';
  tipoProyecto = '';

  // Se llenarán desde la base cuando se conecte la API.
  carreras: OpcionCatalogo[] = [];
  tematicas: OpcionCatalogo[] = [];
  materias: OpcionCatalogo[] = [];

  get totalRecursos(): number {
    return this.pdfs.length + this.archivosZip.length + this.enlaces.length;
  }

  agregarAutor(): void {
    this.autores.push({ nombres: '', apellidos: '', carnet: '' });
  }

  quitarAutor(indice: number): void {
    if (this.autores.length > 1) {
      this.autores.splice(indice, 1);
    }
  }

  actualizarAutor(
    indice: number,
    campo: keyof AutorFormulario,
    event: Event
  ): void {
    const input = event.target as HTMLInputElement;
    const autor = this.autores[indice];

    if (!autor) {
      return;
    }

    autor[campo] = input.value;
  }

  actualizarTipoProyecto(event: Event): void {
    const select = event.target as HTMLSelectElement;
    this.tipoProyecto = select.value;
    this.mensajeError = '';
  }

  actualizarPdfs(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.pdfs = Array.from(input.files ?? []);
    this.mensajeError = '';
  }

  actualizarZips(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.archivosZip = Array.from(input.files ?? []);
    this.mensajeError = '';
  }

  actualizarEnlaces(event: Event): void {
    const textarea = event.target as HTMLTextAreaElement;

    this.enlaces = textarea.value
      .split('\n')
      .map(enlace => enlace.trim())
      .filter(enlace => enlace.length > 0);

    this.mensajeError = '';
  }

  actualizarPalabrasClave(event: Event): void {
    const textarea = event.target as HTMLTextAreaElement;

    this.palabrasClave = textarea.value
      .split('\n')
      .map(palabra => palabra.trim())
      .filter(palabra => palabra.length > 0);
  }

  private enlacesValidos(): boolean {
    return this.enlaces.every(enlace => {
      try {
        const url = new URL(enlace);
        return url.protocol === 'http:' || url.protocol === 'https:';
      } catch {
        return false;
      }
    });
  }

  enviarSolicitud(event: Event): void {
    event.preventDefault();

    const formulario = event.target as HTMLFormElement;

    if (!formulario.checkValidity()) {
      formulario.reportValidity();
      return;
    }

    if (this.totalRecursos === 0) {
      this.mensajeError = 'Agrega al menos un PDF, un enlace o un archivo ZIP.';
      return;
    }

    if (!this.enlacesValidos()) {
      this.mensajeError = 'Revisa los enlaces. Deben comenzar con http:// o https://.';
      return;
    }

    const esTrabajoDeGrado = this.tipoProyecto === 'trabajo-grado';
    const tienePdf = this.pdfs.some(
      archivo => archivo.name.toLowerCase().endsWith('.pdf')
    );

    if (esTrabajoDeGrado && !tienePdf) {
      this.mensajeError = 'Para un trabajo de grado debes adjuntar el PDF completo.';
      return;
    }

    this.mensajeError = '';

    window.alert(
      `Formulario validado con ${this.totalRecursos} recurso(s). ` +
      'Todavía no se guarda porque falta conectar la API.'
    );
  }
}