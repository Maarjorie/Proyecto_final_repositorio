import { Component, ElementRef, computed, inject, input, model, signal } from '@angular/core';

/** Opción del selector. `grupo` agrupa la lista; `detalle` es un texto secundario. */
export interface OpcionBuscable {
  value: string;
  label: string;
  grupo?: string;
  detalle?: string;
}

/** Minúsculas y sin tildes: "Informática" y "informatica" coinciden. */
function normalizar(texto: string): string {
  return texto.normalize('NFD').replace(/[̀-ͯ]/g, '').toLocaleLowerCase('es');
}

let siguienteId = 0;

/**
 * Lista desplegable con buscador, para listas largas (temáticas, docentes,
 * cuentas). Se escribe para filtrar y solo se muestran las primeras
 * coincidencias, así sirve igual con 10 que con 10 000 registros.
 */
@Component({
  selector: 'app-selector-buscable',
  standalone: true,
  templateUrl: './selector-buscable.html',
  styleUrl: './selector-buscable.css',
  host: { '(document:pointerdown)': 'alTocarFuera($event)' }
})
export class SelectorBuscable {
  private readonly host = inject<ElementRef<HTMLElement>>(ElementRef);

  readonly opciones = input<OpcionBuscable[]>([]);
  /** Valor elegido ('' = nada). Admite [(valor)]. */
  readonly valor = model<string>('');
  readonly placeholder = input('Escribe para buscar…');
  readonly textoSinResultados = input('No hay coincidencias.');
  readonly inputId = input('');
  readonly etiqueta = input('');
  readonly deshabilitado = input(false);
  readonly requerido = input(false);

  /** Cuántas coincidencias se pintan como máximo; el resto se afina escribiendo. */
  readonly limite = 50;
  readonly listaId = 'selector-buscable-' + ++siguienteId;

  readonly abierto = signal(false);
  readonly texto = signal('');
  readonly activa = signal(0);

  readonly seleccionada = computed(() => this.opciones().find(opcion => opcion.value === this.valor()) ?? null);

  readonly coincidencias = computed(() => {
    const terminos = normalizar(this.texto().trim()).split(/\s+/).filter(Boolean);
    if (!terminos.length) return this.opciones();
    return this.opciones().filter(opcion => {
      const texto = normalizar(`${opcion.label} ${opcion.detalle ?? ''} ${opcion.grupo ?? ''}`);
      return terminos.every(termino => texto.includes(termino));
    });
  });
  readonly visibles = computed(() => this.coincidencias().slice(0, this.limite));
  readonly ocultas = computed(() => this.coincidencias().length - this.visibles().length);

  /** Cerrado muestra lo elegido; abierto, lo que se va escribiendo. */
  readonly textoCampo = computed(() => (this.abierto() ? this.texto() : this.seleccionada()?.label ?? ''));

  abrir(): void {
    if (this.deshabilitado() || this.abierto()) return;
    this.texto.set('');
    this.activa.set(Math.max(0, this.visibles().findIndex(opcion => opcion.value === this.valor())));
    this.abierto.set(true);
    this.mostrarActiva();
  }

  cerrar(): void {
    this.abierto.set(false);
    this.texto.set('');
  }

  escribir(texto: string): void {
    this.texto.set(texto);
    this.activa.set(0);
    this.abierto.set(true);
  }

  elegir(opcion: OpcionBuscable): void {
    this.valor.set(opcion.value);
    this.cerrar();
  }

  limpiar(campo: HTMLInputElement): void {
    this.valor.set('');
    this.cerrar();
    campo.focus();
  }

  /** Un encabezado de grupo antes de la primera opción de cada grupo. */
  iniciaGrupo(indice: number): boolean {
    const lista = this.visibles();
    return !!lista[indice].grupo && (indice === 0 || lista[indice - 1].grupo !== lista[indice].grupo);
  }

  teclado(evento: KeyboardEvent): void {
    const total = this.visibles().length;
    switch (evento.key) {
      case 'ArrowDown':
        evento.preventDefault();
        if (!this.abierto()) {
          this.abrir();
        } else if (total) {
          this.activa.set(Math.min(total - 1, this.activa() + 1));
          this.mostrarActiva();
        }
        break;
      case 'ArrowUp':
        evento.preventDefault();
        this.activa.set(Math.max(0, this.activa() - 1));
        this.mostrarActiva();
        break;
      case 'Enter':
        if (this.abierto()) {
          evento.preventDefault();
          const opcion = this.visibles()[this.activa()];
          if (opcion) this.elegir(opcion);
        }
        break;
      case 'Escape':
        if (this.abierto()) {
          // Que no cierre también la ventana en la que está el selector.
          evento.preventDefault();
          evento.stopPropagation();
          this.cerrar();
        }
        break;
      case 'Tab':
        this.cerrar();
        break;
    }
  }

  alTocarFuera(evento: Event): void {
    if (this.abierto() && !this.host.nativeElement.contains(evento.target as Node)) {
      this.cerrar();
    }
  }

  private mostrarActiva(): void {
    queueMicrotask(() =>
      this.host.nativeElement.querySelector('.activa')?.scrollIntoView({ block: 'nearest' })
    );
  }
}
