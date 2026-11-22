import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';
import { SesionUsuarioComponent } from '../../auth/sesion-usuario';
import { OpcionBuscable, SelectorBuscable } from '../../compartido/selector-buscable';

const API_URL = 'https://localhost:7244/api';

/** RF-12: proyectos registrados por año y área (GET /api/revision/estadisticas). */
interface Estadisticas {
  anios: number[];
  total: number;
  totalesPorAnio: number[];
  areas: { id: number; nombre: string; porAnio: number[]; total: number }[];
}

interface FilaConteo {
  id: number;
  nombre: string;
  valores: number[];
  total: number;
}

/**
 * RF-12: cuántos proyectos se registraron por año y área temática. Cada
 * proyecto cuenta una vez y las combinaciones sin proyectos valen cero.
 */
@Component({
  selector: 'app-estadisticas',
  standalone: true,
  imports: [SesionUsuarioComponent, RouterLink, RouterLinkActive, SelectorBuscable],
  templateUrl: './estadisticas.html',
  // Comparte el aspecto del panel de supervisión.
  styleUrls: [
    '../../publicaciones/seguimiento/seguimiento.css',
    '../revision-supervisor/revision-supervisor.css',
    './estadisticas.css'
  ]
})
export class EstadisticasComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly cdr = inject(ChangeDetectorRef);

  estadisticas: Estadisticas | null = null;
  cargando = false;
  mensajeError = '';

  // Filtros ('' = todos).
  filtroAnio = '';
  filtroArea = '';

  ngOnInit(): void {
    let token: string | null = null;
    try {
      token = globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
    } catch {
      token = null;
    }
    if (!token) {
      this.mensajeError = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.cargando = true;
    this.http
      .get<Estadisticas>(API_URL + '/revision/estadisticas', { headers: { Authorization: 'Bearer ' + token } })
      .subscribe({
        next: datos => {
          this.estadisticas = datos;
          this.cargando = false;
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          this.cargando = false;
          this.mensajeError = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  formatearArea(nombre: string): string {
    return nombre.charAt(0).toLocaleUpperCase('es-SV') + nombre.slice(1);
  }

  /** Áreas para el buscador (todas, también las que aún no tienen proyectos). */
  private cacheAreas: { origen: Estadisticas | null; opciones: OpcionBuscable[] } = { origen: null, opciones: [] };
  get opcionesAreas(): OpcionBuscable[] {
    if (this.cacheAreas.origen !== this.estadisticas) {
      this.cacheAreas = {
        origen: this.estadisticas,
        opciones: (this.estadisticas?.areas ?? [])
          .map(area => ({ value: String(area.id), label: this.formatearArea(area.nombre) }))
          .sort((a, b) => a.label.localeCompare(b.label, 'es'))
      };
    }
    return this.cacheAreas.opciones;
  }

  /**
   * Tabla según los filtros. Sin área elegida se listan las que tienen
   * proyectos (de más a menos); con un área elegida se muestra aunque sea 0.
   */
  get vista(): { anios: number[]; filas: FilaConteo[]; totales: number[]; total: number } {
    const datos = this.estadisticas;
    if (!datos) return { anios: [], filas: [], totales: [], total: 0 };
    const indices = datos.anios
      .map((anio, indice) => ({ anio, indice }))
      .filter(item => !this.filtroAnio || String(item.anio) === this.filtroAnio);
    const filas = datos.areas
      .filter(area => !this.filtroArea || String(area.id) === this.filtroArea)
      .map(area => {
        const valores = indices.map(item => area.porAnio[item.indice] ?? 0);
        return { id: area.id, nombre: area.nombre, valores, total: valores.reduce((a, b) => a + b, 0) };
      })
      .filter(fila => this.filtroArea || fila.total > 0)
      .sort((a, b) => b.total - a.total || a.nombre.localeCompare(b.nombre, 'es'));
    const totales = indices.map((_, columna) => filas.reduce((suma, fila) => suma + fila.valores[columna], 0));
    return { anios: indices.map(item => item.anio), filas, totales, total: totales.reduce((a, b) => a + b, 0) };
  }

  elegirAnio(event: Event): void {
    this.filtroAnio = (event.target as HTMLSelectElement).value;
  }

  limpiarFiltros(): void {
    this.filtroAnio = '';
    this.filtroArea = '';
  }

  private mensajeErrorApi(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      const mensajeApi = error.error && typeof error.error.mensaje === 'string' ? error.error.mensaje : null;
      if (mensajeApi) return mensajeApi;
      if (error.status === 0) return 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.';
      if (error.status === 401) return 'Tu sesión venció. Inicia sesión de nuevo.';
      if (error.status === 403) return 'Tu cuenta no tiene el rol de supervisor.';
      if (error.status === 404) return 'La API en ejecución no tiene esta función. Recompílala y vuelve a iniciarla.';
    }
    return 'No se pudo cargar el conteo. Inténtalo de nuevo.';
  }
}
