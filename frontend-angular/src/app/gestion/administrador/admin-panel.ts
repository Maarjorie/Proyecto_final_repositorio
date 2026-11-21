import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { Component, computed, effect, inject, input, signal, untracked } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { AUTH_TOKEN_KEY, AUTH_USER_KEY } from '../../auth/auth.constants';
import { cerrarSesion, usuarioTieneRol } from '../../auth/auth.guard';
import { SesionUsuarioComponent } from '../../auth/sesion-usuario';

const API_URL = 'https://localhost:7244/api';

type Role = 'Solicitante' | 'Supervisor' | 'Administrador';

/** En la base de datos el rol de solicitante se llama "usuario". */
const ROL_API: Record<Role, string> = {
  Solicitante: 'usuario',
  Supervisor: 'supervisor',
  Administrador: 'administrador'
};

interface AdminUser {
  id: number;
  username: string;
  name: string;
  roles: Role[];
  active: boolean;
  codigoDocente: string | null;
}

interface UsuarioApi {
  id: number;
  correo: string;
  nombres: string;
  apellidos: string;
  activo: boolean;
  roles: string[];
  codigoDocente: string | null;
}

type AdminTab = 'cuentas' | 'materias' | 'tematicas' | 'carreras' | 'departamentos';
type CatalogKey = Exclude<AdminTab, 'cuentas'>;
/** Fuente de una lista desplegable: otro catálogo o los docentes registrados. */
type OptionSource = CatalogKey | 'docentes';
type CatalogRow = Record<string, string> & { id: string };

interface CatalogField {
  key: string;
  label: string;
  required?: boolean;
  /** Si existe, el campo es una lista desplegable con los registros de esa fuente. */
  optionsFrom?: OptionSource;
  /** Campo que se envía a la API con el id elegido en la lista. */
  apiKey?: string;
}

interface CatalogDef {
  tab: CatalogKey;
  label: string;
  singular: string;
  description: string;
  fields: CatalogField[];
}

interface Option {
  value: string;
  label: string;
}

type PendingChange =
  | { kind: 'role'; id: number; role: Role; enabled: boolean }
  | { kind: 'active'; id: number }
  | { kind: 'delete'; catalog: CatalogKey; id: string };

@Component({
  selector: 'app-admin-panel',
  standalone: true,
  imports: [FormsModule, RouterLink, SesionUsuarioComponent],
  templateUrl: './admin-panel.html',
  styleUrl: './admin-panel.css'
})
export class AdminPanel {
  private readonly router = inject(Router);
  private readonly http = inject(HttpClient);

  readonly roles: { name: Role; description: string }[] = [
    {
      name: 'Solicitante',
      description: 'Envía trabajos para revisión, consulta el estado de sus entregas y reenvía versiones corregidas.'
    },
    {
      name: 'Supervisor',
      description: 'Revisa las entregas, registra el permiso de los autores, aprueba, pide correcciones o rechaza, y retira publicaciones.'
    },
    {
      name: 'Administrador',
      description: 'Gestiona cuentas y roles. Para aprobar o retirar publicaciones también necesita el rol de Supervisor.'
    }
  ];
  readonly roleNames: Role[] = this.roles.map(role => role.name);

  readonly tabs: { tab: AdminTab; label: string }[] = [
    { tab: 'cuentas', label: 'Cuentas y accesos' },
    { tab: 'materias', label: 'Materias' },
    { tab: 'tematicas', label: 'Temáticas' },
    { tab: 'carreras', label: 'Carreras' },
    { tab: 'departamentos', label: 'Departamentos' }
  ];

  readonly catalogDefs: Record<CatalogKey, CatalogDef> = {
    materias: {
      tab: 'materias', label: 'Materias', singular: 'materia',
      description: 'Asignaturas a las que pueden pertenecer los proyectos de curso. Cada una tiene un docente responsable.',
      fields: [
        { key: 'codigo', label: 'Código', required: true },
        { key: 'nombre', label: 'Nombre', required: true },
        { key: 'docente', label: 'Docente', required: true, optionsFrom: 'docentes', apiKey: 'idDocente' },
        { key: 'descripcion', label: 'Descripción' }
      ]
    },
    tematicas: {
      tab: 'tematicas', label: 'Temáticas', singular: 'temática',
      description: 'Áreas temáticas con las que se clasifican y filtran los trabajos.',
      fields: [
        { key: 'nombre', label: 'Nombre', required: true },
        { key: 'descripcion', label: 'Descripción' }
      ]
    },
    carreras: {
      tab: 'carreras', label: 'Carreras', singular: 'carrera',
      description: 'Carreras a las que pertenecen los trabajos. Cada una depende de un departamento.',
      fields: [
        { key: 'codigo', label: 'Código', required: true },
        { key: 'nombre', label: 'Nombre', required: true },
        { key: 'departamento', label: 'Departamento', required: true, optionsFrom: 'departamentos', apiKey: 'idDepartamento' }
      ]
    },
    departamentos: {
      tab: 'departamentos', label: 'Departamentos', singular: 'departamento',
      description: 'Departamentos académicos que agrupan las carreras.',
      fields: [
        { key: 'nombre', label: 'Nombre', required: true },
        { key: 'descripcion', label: 'Descripción' }
      ]
    }
  };

  /** Parte de la ruta /admin/:seccion (llega por enlace de componente). */
  readonly seccion = input<string>();
  readonly activeTab = computed<AdminTab>(() => {
    const value = this.seccion();
    return this.tabs.find(item => item.tab === value)?.tab ?? 'cuentas';
  });
  /** Giro de entrada: gira desde el lado hacia el que se avanza en las pestañas. */
  readonly flipFrom = signal('rotateY(-70deg)');
  private lastTabIndex = 0;
  readonly catalogData = signal<Record<CatalogKey, CatalogRow[]>>({
    materias: [], tematicas: [], carreras: [], departamentos: []
  });
  readonly docentes = signal<Option[]>([]);
  readonly draft = signal<Record<string, string>>({});
  readonly loading = signal(false);
  readonly saving = signal(false);

  readonly activeCatalog = computed<CatalogDef | null>(() => {
    const tab = this.activeTab();
    return tab === 'cuentas' ? null : this.catalogDefs[tab];
  });

  readonly pageTitle = computed(() =>
    this.activeTab() === 'cuentas' ? 'Cuentas y accesos' : this.catalogDefs[this.activeTab() as CatalogKey].label
  );

  readonly filteredCatalogRows = computed(() => {
    const catalog = this.activeCatalog();
    if (!catalog) return [];
    const query = this.search().trim().toLowerCase();
    const rows = this.catalogData()[catalog.tab];
    if (!query) return rows;
    return rows.filter(row =>
      catalog.fields.some(field => (row[field.key] ?? '').toLowerCase().includes(query))
    );
  });

  // Registro de docentes (necesario para crear materias).
  readonly docenteUserId = signal('');
  readonly docenteCode = signal('');
  readonly actionNotice = signal('');
  readonly search = signal('');
  readonly showRolesHelp = signal(false);
  readonly esSupervisor = usuarioTieneRol('supervisor');
  private readonly ownId = this.sessionUserId();

  readonly users = signal<AdminUser[]>([]);

  readonly filteredUsers = computed(() => {
    const query = this.search().trim().toLowerCase();
    if (!query) return this.users();
    return this.users().filter(user =>
      user.username.toLowerCase().includes(query) || user.name.toLowerCase().includes(query)
    );
  });

  /** Cuentas que todavía no son docentes, para el formulario de registro. */
  readonly nonTeacherUsers = computed(() => this.users().filter(user => !user.codigoDocente));

  // Confirmación con contraseña del administrador
  readonly pending = signal<PendingChange | null>(null);
  readonly password = signal('');
  readonly passwordError = signal('');
  readonly verifying = signal(false);

  readonly pendingDescription = computed(() => {
    const change = this.pending();
    if (!change) return '';
    if (change.kind === 'delete') {
      const row = this.catalogData()[change.catalog].find(item => item.id === change.id);
      return row
        ? 'Eliminar «' + (row['nombre'] ?? '') + '» de ' + this.catalogDefs[change.catalog].label + '.'
        : '';
    }
    const user = this.users().find(item => item.id === change.id);
    if (!user) return '';
    if (change.kind === 'role') {
      return (change.enabled ? 'Asignar' : 'Quitar') + ' el rol ' + change.role +
        (change.enabled ? ' a ' : ' de ') + user.username + '.';
    }
    return (user.active ? 'Deshabilitar' : 'Habilitar') + ' la cuenta de ' + user.username + '.';
  });

  readonly navegar = {
    emit: (pantalla: 'catalog' | 'admin' | 'supervisor' | 'login'): void => {
      if (pantalla === 'login') {
        cerrarSesion();
      }

      const rutas = {
        catalog: '/catalogo',
        admin: '/admin',
        supervisor: '/revision-supervisor',
        login: '/iniciar-sesion'
      };

      void this.router.navigateByUrl(rutas[pantalla]);
    }
  };

  constructor() {
    effect(() => {
      const tab = this.activeTab();
      const index = this.tabs.findIndex(item => item.tab === tab);
      untracked(() => {
        this.flipFrom.set(index >= this.lastTabIndex ? 'rotateY(-70deg)' : 'rotateY(70deg)');
        this.lastTabIndex = index;
        this.search.set('');
        this.draft.set({});
        this.actionNotice.set('');
        void this.loadTab(tab);
      });
    });
  }

  /** Esta cuenta no puede quitarse el rol de administrador ni deshabilitarse. */
  isSelf(user: AdminUser): boolean {
    return user.id === this.ownId;
  }

  setDraft(key: string, value: string): void {
    this.draft.update(current => ({ ...current, [key]: value }));
  }

  optionsFor(field: CatalogField): Option[] {
    if (!field.optionsFrom) return [];
    if (field.optionsFrom === 'docentes') return this.docentes();
    return this.catalogData()[field.optionsFrom].map(row => ({ value: row.id, label: row['nombre'] ?? '' }));
  }

  async addCatalogRow(): Promise<void> {
    const catalog = this.activeCatalog();
    if (!catalog || this.saving()) return;
    const draft = this.draft();
    const missing = catalog.fields.some(field => field.required && !(draft[field.key] ?? '').trim());
    if (missing) {
      this.actionNotice.set('Completa los campos obligatorios.');
      return;
    }

    const body: Record<string, string | number> = {};
    for (const field of catalog.fields) {
      const value = (draft[field.key] ?? '').trim();
      if (!value) continue;
      if (field.apiKey) {
        body[field.apiKey] = Number(value);
      } else {
        body[field.key] = value;
      }
    }

    this.saving.set(true);
    try {
      const respuesta = await firstValueFrom(
        this.http.post<{ mensaje: string }>(API_URL + '/admin/catalogos/' + catalog.tab, body, this.options())
      );
      this.draft.set({});
      this.actionNotice.set(respuesta.mensaje);
      await this.loadCatalog(catalog.tab);
    } catch (error: unknown) {
      this.actionNotice.set(this.errorMessage(error));
    } finally {
      this.saving.set(false);
    }
  }

  requestDelete(catalog: CatalogKey, id: string): void {
    this.openPasswordDialog({ kind: 'delete', catalog, id });
  }

  initials(user: AdminUser): string {
    return user.name
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map(part => part[0].toUpperCase())
      .join('');
  }

  /** Registra una cuenta existente como docente para poder asignarle materias. */
  async registerTeacher(): Promise<void> {
    const idUsuario = Number(this.docenteUserId());
    const codigo = this.docenteCode().trim();
    if (!idUsuario || !codigo) {
      this.actionNotice.set('Elige la cuenta y escribe su código docente.');
      return;
    }

    this.saving.set(true);
    try {
      const respuesta = await firstValueFrom(
        this.http.post<{ mensaje: string }>(API_URL + '/admin/docentes', { idUsuario, codigo }, this.options())
      );
      this.docenteUserId.set('');
      this.docenteCode.set('');
      this.actionNotice.set(respuesta.mensaje);
      await this.loadUsers();
    } catch (error: unknown) {
      this.actionNotice.set(this.errorMessage(error));
    } finally {
      this.saving.set(false);
    }
  }

  /** Solicita un cambio de permisos: no se aplica hasta confirmar la contraseña. */
  requestRoleChange(user: AdminUser, role: Role, enabled: boolean): void {
    if (this.isSelf(user) && role === 'Administrador' && !enabled) return;
    this.openPasswordDialog({ kind: 'role', id: user.id, role, enabled });
  }

  requestActiveChange(user: AdminUser): void {
    if (this.isSelf(user)) return;
    this.openPasswordDialog({ kind: 'active', id: user.id });
  }

  private openPasswordDialog(change: PendingChange): void {
    this.password.set('');
    this.passwordError.set('');
    this.pending.set(change);
  }

  cancelPending(): void {
    if (this.verifying()) return;
    this.pending.set(null);
    this.password.set('');
    this.passwordError.set('');
  }

  async confirmPending(): Promise<void> {
    const change = this.pending();
    if (!change || this.verifying()) return;

    if (!this.password()) {
      this.passwordError.set('Escribe tu contraseña.');
      return;
    }

    this.verifying.set(true);
    this.passwordError.set('');

    try {
      // La API vuelve a comprobar la contraseña de esta cuenta antes de aplicar el cambio.
      const mensaje = await this.applyChange(change, this.password());
      this.pending.set(null);
      this.password.set('');
      this.actionNotice.set(mensaje);
    } catch (error: unknown) {
      this.passwordError.set(this.errorMessage(error));
    } finally {
      this.verifying.set(false);
    }
  }

  private async applyChange(change: PendingChange, contrasena: string): Promise<string> {
    if (change.kind === 'delete') {
      const respuesta = await firstValueFrom(this.http.post<{ mensaje: string }>(
        API_URL + '/admin/catalogos/' + change.catalog + '/' + change.id + '/eliminar',
        { contrasena },
        this.options()
      ));
      await this.loadCatalog(change.catalog);
      return respuesta.mensaje;
    }

    const user = this.users().find(item => item.id === change.id);
    if (change.kind === 'role') {
      const respuesta = await firstValueFrom(this.http.put<{ mensaje: string }>(
        API_URL + '/admin/usuarios/' + change.id + '/roles',
        { rol: ROL_API[change.role], asignar: change.enabled, contrasena },
        this.options()
      ));
      await this.loadUsers();
      return respuesta.mensaje;
    }

    const respuesta = await firstValueFrom(this.http.put<{ mensaje: string }>(
      API_URL + '/admin/usuarios/' + change.id + '/activo',
      { activo: !(user?.active ?? true), contrasena },
      this.options()
    ));
    await this.loadUsers();
    return respuesta.mensaje;
  }

  // ----- Carga de datos -----

  private async loadTab(tab: AdminTab): Promise<void> {
    this.loading.set(true);
    try {
      if (tab === 'cuentas') {
        await this.loadUsers();
      } else {
        await this.loadCatalog(tab);
        if (tab === 'carreras') await this.loadCatalog('departamentos');
        if (tab === 'materias') await this.loadTeachers();
      }
    } catch (error: unknown) {
      this.actionNotice.set(this.errorMessage(error));
    } finally {
      this.loading.set(false);
    }
  }

  private async loadUsers(): Promise<void> {
    const datos = await firstValueFrom(
      this.http.get<UsuarioApi[]>(API_URL + '/admin/usuarios', this.options())
    );
    this.users.set(datos.map(usuario => ({
      id: usuario.id,
      username: usuario.correo,
      name: (usuario.nombres + ' ' + usuario.apellidos).trim(),
      roles: this.roleNames.filter(role => usuario.roles.includes(ROL_API[role])),
      active: usuario.activo,
      codigoDocente: usuario.codigoDocente
    })));
  }

  private async loadCatalog(catalog: CatalogKey): Promise<void> {
    const datos = await firstValueFrom(
      this.http.get<Record<string, string | number | null>[]>(
        API_URL + '/admin/catalogos/' + catalog, this.options())
    );
    const rows: CatalogRow[] = datos.map(item => {
      const row: CatalogRow = { id: String(item['id']) };
      for (const [key, value] of Object.entries(item)) {
        if (key !== 'id') row[key] = value === null ? '' : String(value);
      }
      return row;
    });
    this.catalogData.update(data => ({ ...data, [catalog]: rows }));
  }

  private async loadTeachers(): Promise<void> {
    const datos = await firstValueFrom(
      this.http.get<{ id: number; codigo: string; nombre: string }[]>(
        API_URL + '/admin/catalogos/docentes', this.options())
    );
    this.docentes.set(datos.map(docente => ({
      value: String(docente.id),
      label: docente.nombre + ' (' + docente.codigo + ')'
    })));
  }

  private options(): { headers: Record<string, string> } {
    let token = '';
    try {
      token = globalThis.sessionStorage?.getItem(AUTH_TOKEN_KEY) ?? '';
    } catch {
      token = '';
    }
    return { headers: { Authorization: 'Bearer ' + token } };
  }

  private sessionUserId(): number | null {
    try {
      const raw = globalThis.sessionStorage?.getItem(AUTH_USER_KEY);
      const id = raw ? (JSON.parse(raw) as { id?: unknown }).id : null;
      return typeof id === 'number' ? id : null;
    } catch {
      return null;
    }
  }

  private errorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      const mensaje = error.error && typeof error.error.mensaje === 'string' ? error.error.mensaje : null;
      if (mensaje) return mensaje;
      if (error.status === 0) return 'No se pudo conectar con la API. Verifica que RepositorioApi esté iniciado.';
      if (error.status === 401) return 'Tu sesión venció. Inicia sesión de nuevo.';
      if (error.status === 403) return 'Tu cuenta no tiene el rol de administrador.';
    }
    return 'No se pudo completar la acción. Inténtalo de nuevo.';
  }
}
