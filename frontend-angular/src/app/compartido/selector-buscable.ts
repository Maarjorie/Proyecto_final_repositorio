import { Component, DestroyRef, ElementRef, computed, effect, inject, input, model, signal, viewChild } from '@angular/core';

/** Opción del selector. `grupo` agrupa la lista; `detalle` es un texto secundario. */
export interface OpcionBuscable {
  value: string;
  label: string;
  grupo?: string;
  detalle?: string;
}

/** Minúsculas y sin tildes. */
function normalizar(texto: string): string {
  return texto.normalize('NFD').replace(/[̀-ͯ]/g, '').toLocaleLowerCase('es');
}

let siguienteId = 0;

/** Lista desplegable con buscador para listas largas. */
@Component({
  selector: 'app-selector-buscable',
  standalone: true,
  templateUrl: './selector-buscable.html',
  styleUrl: './selector-buscable.css',
  host: { '(document:pointerdown)': 'alTocarFuera($event)' }
})
export class SelectorBuscable {
  private readonly host = inject<ElementRef<HTMLElement>>(ElementRef);
  private readonly campo = viewChild.required<ElementRef<HTMLInputElement>>('campo');
  private readonly lista = viewChild<ElementRef<HTMLUListElement>>('lista');

  constructor() {
    // La lista va en <body> para que ningún contenedor la recorte.
    const reubicar = () => this.posicionar();
    effect(onCleanup => {
      const lista = this.lista()?.nativeElement;
      if (!lista) return;
      document.body.appendChild(lista);
      this.posicionar();
      globalThis.addEventListener('scroll', reubicar, true);
      globalThis.addEventListener('resize', reubicar);
      onCleanup(() => {
        globalThis.removeEventListener('scroll', reubicar, true);
        globalThis.removeEventListener('resize', reubicar);
      });
    });
    inject(DestroyRef).onDestroy(() => this.lista()?.nativeElement.remove());
  }

  readonly opciones = input<OpcionBuscable[]>([]);
  /** Valor elegido ('' = nada). Admite [(valor)]. */
  readonly valor = model<string>('');
  readonly placeholder = input('Buscar');
  readonly textoSinResultados = input('Sin resultados');
  readonly inputId = input('');
  readonly etiqueta = input('');
  readonly deshabilitado = input(false);
  readonly requerido = input(false);

  /** Máximo de coincidencias visibles. */
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
          // Evita cerrar también la ventana que contiene el selector.
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
    const objetivo = evento.target as Node;
    if (this.abierto() && !this.host.nativeElement.contains(objetivo) &&
        !this.lista()?.nativeElement.contains(objetivo)) {
      this.cerrar();
    }
  }

  /** Debajo del campo, o encima si abajo no hay espacio. */
  private posicionar(): void {
    const lista = this.lista()?.nativeElement;
    if (!lista) return;
    const caja = this.campo().nativeElement.getBoundingClientRect();
    // En teléfono la página tiene zoom; las medidas de pantalla se pasan a las de la lista.
    const zoom = (lista as HTMLElement & { currentCSSZoom?: number }).currentCSSZoom || 1;
    const px = (valor: number) => valor / zoom + 'px';
    const abajo = globalThis.innerHeight - caja.bottom - 12;
    const arriba = caja.top - 12;
    const haciaArriba = abajo < 200 && arriba > abajo;
    lista.style.left = px(caja.left);
    lista.style.width = px(caja.width);
    lista.style.maxHeight = px(Math.max(120, Math.min(280, haciaArriba ? arriba : abajo)));
    lista.style.top = haciaArriba ? '' : px(caja.bottom + 6);
    lista.style.bottom = haciaArriba ? px(globalThis.innerHeight - caja.top + 6) : '';
  }

  private mostrarActiva(): void {
    queueMicrotask(() =>
      this.lista()?.nativeElement.querySelector('.activa')?.scrollIntoView({ block: 'nearest' })
    );
  }
}
