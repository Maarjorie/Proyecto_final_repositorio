import { SesionUsuarioComponent } from '../../auth/sesion-usuario';
import { esCuentaDeGestion, usuarioTieneRol } from '../../auth/auth.guard';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject, OnInit } from '@angular/core';
import { ActivatedRoute, RouterLink, RouterLinkActive } from '@angular/router';
import { firstValueFrom, retry } from 'rxjs';
import { AUTH_TOKEN_KEY } from '../../auth/auth.constants';
import { OpcionBuscable, SelectorBuscable } from '../../compartido/selector-buscable';

interface AutorFormulario {
  nombres: string;
  apellidos: string;
  carnet: string;
}

interface OpcionCatalogo {
  id: number;
  nombre: string;
}

interface RespuestaEnvio {
  idProyecto: number;
  idEntrega: number;
  estado: string;
  publicado: boolean;
  mensaje: string;
}

/** Datos de la versión observada que se precargan al corregir (RF-20). */
interface SolicitudACorregir {
  id: number;
  puedeReenviar: boolean;
  version: number;
  titulo: string;
  resumen: string;
  anio: number;
  idTipoProyecto: number;
  idDepartamento: number;
  idCarrera: number;
  idTematica: number;
  idMateria: number | null;
  autores: { nombres: string; apellidos: string; carnet: string | null }[];
  palabrasClave: string[];
  asesores: { idDocente: number; nombre: string; autorizado: boolean }[];
  recursos: { id: number; nombre: string; tipo: string; url: string | null }[];
  observaciones: { fecha: string; mensaje: string }[];
}

/** Docente que puede asesorar un trabajo (GET /api/catalogos/docentes). */
interface DocenteCatalogo {
  id: number;
  codigo: string;
  nombres: string;
  apellidos: string;
  idDepartamento: number;
  departamento: string;
}

/** Materia del plan de la carrera elegida (GET /api/catalogos/materias?carreraId=). */
interface MateriaCatalogo {
  id: number;
  codigo: string;
  nombre: string;
  ciclo: number;
}

const ROMANOS = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];

type DepartamentoCatalogo = OpcionCatalogo;

interface CarreraCatalogo extends OpcionCatalogo {
  departamentoId: number;
}

const API_URL = 'https://localhost:7244/api';

@Component({
  selector: 'app-envio-proyecto',
  standalone: true,
  imports: [SesionUsuarioComponent, RouterLink, RouterLinkActive, SelectorBuscable],
  templateUrl: './envio-proyecto.html',
  styleUrl: './envio-proyecto.css'
})
export class EnvioProyectoComponent implements OnInit {
  private readonly http = inject(HttpClient);
  // La app es zoneless: tras una respuesta HTTP hay que avisar a Angular
  // para que vuelva a pintar la vista.
  private readonly cdr = inject(ChangeDetectorRef);

  autores: AutorFormulario[] = [
    { nombres: '', apellidos: '', carnet: '' }
  ];

  pdfs: File[] = [];
  archivosZip: File[] = [];
  enlaces: string[] = [];
  palabrasClave: string[] = [];
  mensajeError = '';
  mensajeExito = '';
  tipoProyecto = '';
  enviando = false;
  solicitudEnviada = false;
  readonly esSupervisor = usuarioTieneRol('supervisor');
  readonly esGestion = esCuentaDeGestion();

  departamentos: DepartamentoCatalogo[] = [];
  carreras: CarreraCatalogo[] = [];
  tiposProyecto: OpcionCatalogo[] = [];
  tematicas: OpcionCatalogo[] = [];
  /** Solo las materias del plan de la carrera elegida. */
  materias: MateriaCatalogo[] = [];
  cargandoMaterias = false;
  docentes: DocenteCatalogo[] = [];

  /** RF-16: ids de los docentes asesores elegidos ('' = sin elegir). Hasta 3. */
  asesores: string[] = [''];

  agregarAsesor(): void {
    if (this.asesores.length < 3) {
      this.asesores = [...this.asesores, ''];
    }
  }

  quitarAsesor(indice: number): void {
    this.asesores = this.asesores.length > 1
      ? this.asesores.filter((_, i) => i !== indice)
      : [''];
  }

  elegirAsesor(indice: number, valor: string): void {
    this.asesores = this.asesores.map((actual, i) => (i === indice ? valor : actual));
    this.limpiarMensajes();
  }

  /** Temáticas para el selector con buscador (49 o más no caben en una lista). */
  private cacheTematicas: { origen: OpcionCatalogo[]; opciones: OpcionBuscable[] } | null = null;
  get opcionesTematicas(): OpcionBuscable[] {
    if (this.cacheTematicas?.origen !== this.tematicas) {
      this.cacheTematicas = {
        origen: this.tematicas,
        opciones: this.tematicas.map(tematica => ({ value: String(tematica.id), label: this.formatearNombre(tematica.nombre) }))
      };
    }
    return this.cacheTematicas.opciones;
  }

  /**
   * Opciones de cada fila de asesor. Se guardan mientras no cambien los datos,
   * para no entregar al selector una lista nueva en cada repintado.
   */
  private cacheAsesores = new Map<number, { clave: string; opciones: OpcionBuscable[] }>();
  opcionesAsesor(indice: number): OpcionBuscable[] {
    const clave = [this.docentes.length, this.departamentos.length, this.departamentoSeleccionado,
      this.asesores.filter((id, i) => i !== indice && id).join(',')].join('|');
    const guardadas = this.cacheAsesores.get(indice);
    if (guardadas?.clave === clave) return guardadas.opciones;
    const opciones = this.gruposDeAsesores(indice).flatMap(grupo =>
      grupo.docentes.map(docente => ({
        value: String(docente.id),
        label: docente.nombres + ' ' + docente.apellidos,
        detalle: docente.codigo + (grupo.titulo ? '' : ' · ' + docente.departamento.replace(/^departamento de\s+/i, '')),
        grupo: grupo.titulo || undefined
      })));
    this.cacheAsesores.set(indice, { clave, opciones });
    return opciones;
  }

  /** Un docente ya elegido en otra fila no se vuelve a ofrecer. */
  docentesDisponibles(indice: number): DocenteCatalogo[] {
    const elegidos = this.asesores.filter((id, i) => i !== indice && id);
    return this.docentes.filter(docente => !elegidos.includes(String(docente.id)));
  }

  /**
   * Con un departamento elegido, primero se ofrecen sus docentes y después
   * los de otros departamentos (un asesor puede ser de otro departamento).
   */
  gruposDeAsesores(indice: number): { titulo: string; docentes: DocenteCatalogo[] }[] {
    const disponibles = this.docentesDisponibles(indice);
    const idDepartamento = Number(this.departamentoSeleccionado);
    if (!idDepartamento) {
      return [{ titulo: '', docentes: disponibles }];
    }
    const propios = disponibles.filter(docente => docente.idDepartamento === idDepartamento);
    const otros = disponibles.filter(docente => docente.idDepartamento !== idDepartamento);
    const nombre = this.departamentos.find(item => item.id === idDepartamento)?.nombre ?? 'este departamento';
    return [
      { titulo: nombre, docentes: propios },
      { titulo: 'Otros departamentos', docentes: otros }
    ].filter(grupo => grupo.docentes.length > 0);
  }

  /** Materias de la carrera agrupadas por ciclo del plan. */
  get materiasPorCiclo(): { titulo: string; materias: MateriaCatalogo[] }[] {
    const ciclos = [...new Set(this.materias.map(materia => materia.ciclo))].sort((a, b) => a - b);
    return ciclos.map(ciclo => ({
      titulo: 'Ciclo ' + (ROMANOS[ciclo] ?? ciclo),
      materias: this.materias.filter(materia => materia.ciclo === ciclo)
    }));
  }

  /** Pide a la API las materias del plan de la carrera. */
  private cargarMaterias(idCarrera: number): void {
    this.materias = [];
    if (!idCarrera) {
      return;
    }
    this.cargandoMaterias = true;
    this.http
      .get<MateriaCatalogo[]>(API_URL + '/catalogos/materias', { params: { carreraId: idCarrera } })
      .subscribe({
        next: datos => {
          this.cargandoMaterias = false;
          this.materias = datos;
          // Si la asignatura elegida no es de esta carrera, se deja sin elegir.
          if (!datos.some(materia => String(materia.id) === this.materiaSeleccionada)) {
            this.materiaSeleccionada = '';
          }
          this.cdr.markForCheck();
        },
        error: () => {
          this.cargandoMaterias = false;
          this.materias = [];
          this.cdr.markForCheck();
        }
      });
  }

  departamentoSeleccionado = '';
  carreraSeleccionada = '';

  // Valores del formulario enlazados para poder precargarlos al corregir.
  titulo = '';
  anio = '';
  resumen = '';
  tematicaSeleccionada = '';
  materiaSeleccionada = '';
  palabrasClaveTexto = '';
  enlacesTexto = '';

  // RF-20: reenvío de una versión corregida.
  private readonly route = inject(ActivatedRoute);
  correccion: SolicitudACorregir | null = null;
  cargandoCorreccion = false;
  errorCorreccion = '';
  conservarRecursos: number[] = [];

  get corrigiendo(): boolean {
    return this.correccion !== null;
  }

  get carrerasFiltradas(): CarreraCatalogo[] {
    const idDepartamento = Number(this.departamentoSeleccionado);

    if (!idDepartamento) {
      return [];
    }

    return this.carreras.filter(
      carrera => carrera.departamentoId === idDepartamento
    );
  }

  get tipoProyectoSeleccionado(): OpcionCatalogo | undefined {
    return this.tiposProyecto.find(tipo => tipo.id === Number(this.tipoProyecto));
  }

  get esProyectoCurso(): boolean {
    return this.tipoProyectoSeleccionado?.nombre.toLowerCase().includes('curso') ?? false;
  }

  formatearNombre(nombre: string): string {
    return nombre.length === 0
      ? nombre
      : nombre.charAt(0).toLocaleUpperCase('es-SV') + nombre.slice(1);
  }

  ngOnInit(): void {
    this.cargarCatalogo<DepartamentoCatalogo>(
      '/catalogos/departamentos',
      'repositorio.catalogos.departamentos',
      datos => this.departamentos = datos,
      'No se pudieron cargar los departamentos.'
    );

    this.cargarCatalogo<CarreraCatalogo>(
      '/catalogos/carreras',
      'repositorio.catalogos.carreras',
      datos => this.carreras = datos,
      'No se pudieron cargar las carreras.'
    );

    this.cargarCatalogo<OpcionCatalogo>(
      '/catalogos/tipos-proyecto',
      'repositorio.catalogos.tipos-proyecto',
      datos => this.tiposProyecto = datos,
      'No se pudieron cargar los tipos de proyecto.'
    );

    this.cargarCatalogo<OpcionCatalogo>(
      '/catalogos/tematicas',
      'repositorio.catalogos.tematicas',
      datos => this.tematicas = datos,
      'No se pudieron cargar las áreas temáticas.'
    );

    this.cargarCatalogo<DocenteCatalogo>(
      '/catalogos/docentes',
      'repositorio.catalogos.docentes',
      datos => this.docentes = datos,
      'No se pudieron cargar los docentes.'
    );

    const corregir = Number(this.route.snapshot.queryParamMap.get('corregir'));
    if (corregir > 0) {
      this.cargarCorreccion(corregir);
    }
  }

  /** RF-20: precarga la versión observada para enviar la corrección. */
  private cargarCorreccion(idEntrega: number): void {
    let token: string | null = null;
    try {
      token = globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
    } catch {
      token = null;
    }
    if (!token) {
      this.errorCorreccion = 'Tu sesión venció. Inicia sesión de nuevo.';
      return;
    }

    this.cargandoCorreccion = true;
    this.http
      .get<SolicitudACorregir>(API_URL + '/proyectos/mis-proyectos/' + idEntrega, {
        headers: { Authorization: 'Bearer ' + token }
      })
      .subscribe({
        next: datos => {
          this.cargandoCorreccion = false;
          if (!datos.puedeReenviar) {
            this.errorCorreccion =
              'Esta solicitud no admite correcciones: el supervisor no las pidió o ya existe una versión más reciente.';
            this.cdr.markForCheck();
            return;
          }

          this.correccion = datos;
          this.titulo = datos.titulo;
          this.resumen = datos.resumen;
          this.anio = String(datos.anio);
          this.tipoProyecto = String(datos.idTipoProyecto);
          this.departamentoSeleccionado = String(datos.idDepartamento);
          this.carreraSeleccionada = String(datos.idCarrera);
          this.tematicaSeleccionada = String(datos.idTematica);
          this.materiaSeleccionada = datos.idMateria ? String(datos.idMateria) : '';
          this.cargarMaterias(datos.idCarrera);
          this.autores = datos.autores.length > 0
            ? datos.autores.map(autor => ({
                nombres: autor.nombres,
                apellidos: autor.apellidos,
                carnet: autor.carnet ?? ''
              }))
            : [{ nombres: '', apellidos: '', carnet: '' }];
          this.palabrasClave = [...datos.palabrasClave];
          this.palabrasClaveTexto = datos.palabrasClave.join('\n');
          this.asesores = (datos.asesores ?? []).length > 0
            ? datos.asesores.map(asesor => String(asesor.idDocente))
            : [''];
          // Por defecto se conservan todos los materiales; el solicitante
          // desmarca los que reemplaza.
          this.conservarRecursos = datos.recursos.map(recurso => recurso.id);
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          this.cargandoCorreccion = false;
          this.errorCorreccion = this.mensajeErrorApi(error);
          this.cdr.markForCheck();
        }
      });
  }

  alternarConservar(idRecurso: number, event: Event): void {
    const marcado = (event.target as HTMLInputElement).checked;
    this.conservarRecursos = marcado
      ? [...this.conservarRecursos, idRecurso]
      : this.conservarRecursos.filter(id => id !== idRecurso);
    this.limpiarMensajes();
  }

  actualizarCampo(
    campo: 'titulo' | 'anio' | 'resumen' | 'tematicaSeleccionada' | 'materiaSeleccionada',
    event: Event
  ): void {
    this[campo] = (event.target as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement).value;
  }

  private cargarCatalogo<T>(
    endpoint: string,
    claveCache: string,
    aplicar: (datos: T[]) => void,
    mensajeError: string
  ): void {
    // Los catálogos siempre se piden a la API: si la API no responde, el
    // formulario queda vacío y avisa, en lugar de mostrar datos guardados.
    // Se borra la copia que guardaban versiones anteriores del formulario.
    try {
      globalThis.sessionStorage.removeItem(claveCache);
    } catch {
      // Sin acceso al almacenamiento no hay copia que borrar.
    }

    this.http
      .get<T[]>(API_URL + endpoint)
      .pipe(retry({ count: 2, delay: 500 }))
      .subscribe({
        next: datos => {
          aplicar(datos);
          this.cdr.markForCheck();
        },
        error: (error: unknown) => {
          console.error('Error al cargar catálogo ' + endpoint + ':', error);
          aplicar([]);
          this.mensajeError = error instanceof HttpErrorResponse && error.status === 0
            ? 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.'
            : mensajeError;
          this.cdr.markForCheck();
        }
      });
  }
  get totalRecursos(): number {
    return this.pdfs.length + this.archivosZip.length + this.enlaces.length +
      this.conservarRecursos.length;
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

  actualizarDepartamento(event: Event): void {
    this.departamentoSeleccionado =
      (event.target as HTMLSelectElement).value;
    this.carreraSeleccionada = '';
    this.materiaSeleccionada = '';
    this.materias = [];
    this.limpiarMensajes();
  }

  actualizarCarrera(event: Event): void {
    this.carreraSeleccionada =
      (event.target as HTMLSelectElement).value;
    // La asignatura depende de la carrera: se vuelve a elegir.
    this.materiaSeleccionada = '';
    this.cargarMaterias(Number(this.carreraSeleccionada));
    this.limpiarMensajes();
  }

  actualizarTipoProyecto(event: Event): void {
    this.tipoProyecto = (event.target as HTMLSelectElement).value;
    this.limpiarMensajes();
  }

  actualizarPdfs(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.pdfs = Array.from(input.files ?? []);
    this.limpiarMensajes();
  }

  actualizarZips(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.archivosZip = Array.from(input.files ?? []);
    this.limpiarMensajes();
  }

  actualizarEnlaces(event: Event): void {
    const textarea = event.target as HTMLTextAreaElement;

    this.enlaces = textarea.value
      .split('\n')
      .map(enlace => enlace.trim())
      .filter(enlace => enlace.length > 0);

    this.limpiarMensajes();
  }

  actualizarPalabrasClave(event: Event): void {
    const textarea = event.target as HTMLTextAreaElement;

    this.palabrasClave = textarea.value
      .split('\n')
      .map(palabra => palabra.trim())
      .filter(palabra => palabra.length > 0);
  }

  private limpiarMensajes(): void {
    this.mensajeError = '';
    this.mensajeExito = '';
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

  private valorFormulario(
    formulario: HTMLFormElement,
    nombre: string
  ): string {
    const control = formulario.elements.namedItem(nombre);

    if (
      control instanceof HTMLInputElement ||
      control instanceof HTMLSelectElement ||
      control instanceof HTMLTextAreaElement
    ) {
      return control.value.trim();
    }

    return '';
  }

  async enviarSolicitud(event: Event): Promise<void> {
    event.preventDefault();

    if (this.enviando || this.solicitudEnviada) {
      return;
    }

    const formulario = event.target as HTMLFormElement;

    if (!formulario.checkValidity()) {
      formulario.reportValidity();
      return;
    }

    if (!this.tematicaSeleccionada) {
      this.mensajeError = 'Selecciona el área temática.';
      formulario.querySelector<HTMLInputElement>('#tematica')?.focus();
      return;
    }

    if (this.totalRecursos === 0) {
      this.mensajeError =
        'Agrega al menos un PDF, un enlace o un archivo ZIP.';
      return;
    }

    if (!this.enlacesValidos()) {
      this.mensajeError =
        'Revisa los enlaces. Deben comenzar con http:// o https://.';
      return;
    }

    const nombreTipo = this.tipoProyectoSeleccionado?.nombre.toLowerCase() ?? '';
    const requierePdf =
      nombreTipo.includes('tesis') || nombreTipo.includes('graduación');
    const conservaPdf = (this.correccion?.recursos ?? []).some(
      recurso => recurso.tipo === 'pdf' && this.conservarRecursos.includes(recurso.id)
    );
    const tienePdf = conservaPdf || this.pdfs.some(
      archivo => archivo.name.toLowerCase().endsWith('.pdf')
    );

    if (requierePdf && !tienePdf) {
      this.mensajeError =
        'Para tesis y trabajos de graduación debes adjuntar el PDF completo.';
      return;
    }

    let token: string | null = null;
    try {
      token = globalThis.sessionStorage.getItem(AUTH_TOKEN_KEY);
    } catch {
      this.mensajeError = 'No se pudo leer la sesión. Inicia sesión de nuevo.';
      return;
    }

    if (!token) {
      this.mensajeError = 'Tu sesión venció. Inicia sesión para enviar el proyecto.';
      return;
    }

    const datos = new FormData();
    datos.append('Titulo', this.valorFormulario(formulario, 'titulo'));
    datos.append('Resumen', this.valorFormulario(formulario, 'resumen'));
    datos.append('Anio', this.valorFormulario(formulario, 'anio'));
    datos.append('IdTipoProyecto', this.tipoProyecto);
    datos.append('IdCarrera', this.carreraSeleccionada);
    datos.append('IdTematica', this.tematicaSeleccionada);
    datos.append('AutoresJson', JSON.stringify(this.autores));
    this.asesores
      .filter(id => id)
      .forEach(id => datos.append('IdDocentesAsesores', id));

    // Solo un proyecto de curso pertenece a una asignatura (RF-04).
    const materia = this.esProyectoCurso ? this.materiaSeleccionada : '';
    if (materia) {
      datos.append('IdMateria', materia);
    }

    this.palabrasClave.forEach(palabra =>
      datos.append('PalabrasClave', palabra)
    );
    this.enlaces.forEach(enlace =>
      datos.append('Enlaces', enlace)
    );
    this.pdfs.forEach(archivo =>
      datos.append('Pdfs', archivo, archivo.name)
    );
    this.archivosZip.forEach(archivo =>
      datos.append('ArchivosZip', archivo, archivo.name)
    );
    this.conservarRecursos.forEach(id =>
      datos.append('ConservarRecursos', String(id))
    );

    this.enviando = true;
    this.limpiarMensajes();

    // RF-20: la corrección se registra como otra entrega del mismo proyecto.
    const url = this.correccion
      ? API_URL + '/proyectos/mis-proyectos/' + this.correccion.id + '/reenvio'
      : API_URL + '/proyectos';

    try {
      const respuesta = await firstValueFrom(
        this.http.post<RespuestaEnvio>(
          url,
          datos,
          { headers: { Authorization: 'Bearer ' + token } }
        )
      );

      this.mensajeExito = respuesta.mensaje;
      this.solicitudEnviada = true;
    } catch (error: unknown) {
      this.mensajeError = this.mensajeErrorApi(error);
    } finally {
      this.enviando = false;
      this.cdr.markForCheck();
    }
  }

  private mensajeErrorApi(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      const mensajeApi =
        error.error && typeof error.error.mensaje === 'string'
          ? error.error.mensaje
          : null;

      if (mensajeApi) {
        return mensajeApi;
      }

      if (error.status === 0) {
        return 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.';
      }

      if (error.status === 401) {
        return 'Tu sesión venció. Inicia sesión de nuevo.';
      }

      if (error.status === 403) {
        return 'Tu cuenta no tiene permiso para enviar proyectos.';
      }
    }

    return 'No se pudo guardar el envío. Revisa los datos e inténtalo de nuevo.';
  }
}
