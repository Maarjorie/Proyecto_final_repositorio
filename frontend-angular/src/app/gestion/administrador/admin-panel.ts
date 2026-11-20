import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { Component, computed, effect, inject, input, signal, untracked } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import {
  AUTH_API_URL,
  AUTH_EXPIRY_KEY,
  AUTH_TOKEN_KEY,
  AUTH_USER_KEY
} from '../../auth/auth.constants';

type Role = 'Solicitante' | 'Supervisor' | 'Administrador';

interface DemoUser {
  id: number;
  username: string;
  name: string;
  roles: Role[];
  active: boolean;
}

type AdminTab = 'cuentas' | 'materias' | 'tematicas' | 'carreras' | 'departamentos';
type CatalogKey = Exclude<AdminTab, 'cuentas'>;
type CatalogRow = Record<string, string> & { id: string };

interface CatalogField {
  key: string;
  label: string;
  required?: boolean;
  /** Si existe, el campo es una lista desplegable con los nombres de ese catálogo. */
  optionsFrom?: CatalogKey;
}

interface CatalogDef {
  tab: CatalogKey;
  label: string;
  singular: string;
  description: string;
  fields: CatalogField[];
}

type PendingChange =
  | { kind: 'role'; id: number; role: Role; enabled: boolean }
  | { kind: 'active'; id: number }
  | { kind: 'delete'; catalog: CatalogKey; id: string };

@Component({
  selector: 'app-admin-panel',
  standalone: true,
  imports: [FormsModule, RouterLink],
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
      description: 'Asignaturas a las que pueden pertenecer los proyectos de curso.',
      fields: [
        { key: 'codigo', label: 'Código', required: true },
        { key: 'nombre', label: 'Nombre', required: true },
        { key: 'docente', label: 'Docente' },
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
        { key: 'departamento', label: 'Departamento', required: true, optionsFrom: 'departamentos' }
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
  readonly draft = signal<Record<string, string>>({});
  private nextCatalogId = 1;

  readonly activeCatalog = computed<CatalogDef | null>(() => {
    const tab = this.activeTab();
    return tab === 'cuentas' ? null : this.catalogDefs[tab];
  });

  readonly pageTitle = computed(() =>
    this.activeTab() === 'cuentas' ? 'Cuentas y acceso' : this.catalogDefs[this.activeTab() as CatalogKey].label
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

  readonly newUsername = signal('');
  readonly newUserName = signal('');
  readonly actionNotice = signal('');
  readonly search = signal('');
  readonly showRolesHelp = signal(false);

  readonly users = signal<DemoUser[]>([
    { id: 1, username: 'admin.demo', name: 'Cuenta de muestra', roles: ['Administrador'], active: true }
  ]);

  readonly filteredUsers = computed(() => {
    const query = this.search().trim().toLowerCase();
    if (!query) return this.users();
    return this.users().filter(user => user.username.toLowerCase().includes(query));
  });

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
      if (pantalla === 'supervisor') {
        this.actionNotice.set('La pantalla de supervisión aún no tiene una ruta configurada.');
        return;
      }

      if (pantalla === 'login') {
        sessionStorage.removeItem(AUTH_TOKEN_KEY);
        sessionStorage.removeItem(AUTH_EXPIRY_KEY);
        sessionStorage.removeItem(AUTH_USER_KEY);
      }

      const rutas = {
        catalog: '/catalogo',
        admin: '/admin',
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
      });
    });
  }

  setDraft(key: string, value: string): void {
    this.draft.update(current => ({ ...current, [key]: value }));
  }

  optionsFor(field: CatalogField): string[] {
    return field.optionsFrom
      ? this.catalogData()[field.optionsFrom].map(row => row['nombre'] ?? '')
      : [];
  }

  addCatalogRow(): void {
    const catalog = this.activeCatalog();
    if (!catalog) return;
    const key = catalog.tab;
    const draft = this.draft();
    const missing = catalog.fields.some(field => field.required && !(draft[field.key] ?? '').trim());
    if (missing) {
      this.actionNotice.set('Completa los campos obligatorios.');
      return;
    }

    const row: CatalogRow = { id: String(this.nextCatalogId++) };
    for (const field of catalog.fields) row[field.key] = (draft[field.key] ?? '').trim();

    const uniqueKey = catalog.fields[0].key;
    const duplicated = this.catalogData()[key].some(
      item => (item[uniqueKey] ?? '').toLowerCase() === row[uniqueKey].toLowerCase()
    );
    if (duplicated) {
      this.actionNotice.set('Ya existe un registro con ese ' + catalog.fields[0].label.toLowerCase() + '.');
      return;
    }

    this.catalogData.update(data => ({ ...data, [key]: [...data[key], row] }));
    this.draft.set({});
    this.actionNotice.set('Registro agregado.');
  }

  requestDelete(catalog: CatalogKey, id: string): void {
    this.openPasswordDialog({ kind: 'delete', catalog, id });
  }

  initials(user: DemoUser): string {
    return user.name
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map(part => part[0].toUpperCase())
      .join('');
  }

  addUser(): void {
    const username = this.newUsername().trim();
    const name = this.newUserName().trim();
    if (!username || !name) {
      this.actionNotice.set('Completa ambos campos.');
      return;
    }
    if (this.users().some(user => user.username.toLowerCase() === username.toLowerCase())) {
      this.actionNotice.set('Ese nombre de usuario ya existe.');
      return;
    }
    const nextId = Math.max(0, ...this.users().map(user => user.id)) + 1;
    this.users.update(users => [...users, { id: nextId, username, name, roles: [], active: true }]);
    this.newUsername.set('');
    this.newUserName.set('');
    this.actionNotice.set('Cuenta de muestra agregada.');
  }

  /** Solicita un cambio de permisos: no se aplica hasta confirmar la contraseña. */
  requestRoleChange(id: number, role: Role, enabled: boolean): void {
    if (id === 1) return;
    this.openPasswordDialog({ kind: 'role', id, role, enabled });
  }

  requestActiveChange(id: number): void {
    if (id === 1) return;
    this.openPasswordDialog({ kind: 'active', id });
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

    const correo = this.sessionEmail();
    if (!correo) {
      this.passwordError.set('No hay una sesión de administrador abierta. Inicia sesión para modificar permisos.');
      return;
    }

    this.verifying.set(true);
    this.passwordError.set('');

    try {
      // Se vuelve a validar la contraseña de la cuenta con la sesión abierta.
      await firstValueFrom(
        this.http.post(AUTH_API_URL + '/login', { correo, contrasena: this.password() })
      );
      this.applyChange(change);
      this.pending.set(null);
      this.password.set('');
      this.actionNotice.set('Cambio aplicado.');
    } catch (error: unknown) {
      this.passwordError.set(this.errorMessage(error));
    } finally {
      this.verifying.set(false);
    }
  }

  private applyChange(change: PendingChange): void {
    if (change.kind === 'delete') {
      this.catalogData.update(data => ({
        ...data,
        [change.catalog]: data[change.catalog].filter(row => row.id !== change.id)
      }));
    } else if (change.kind === 'role') {
      this.users.update(users => users.map(user => {
        if (user.id !== change.id || user.roles.includes(change.role) === change.enabled) return user;
        const roles = change.enabled
          ? [...user.roles, change.role]
          : user.roles.filter(value => value !== change.role);
        return { ...user, roles };
      }));
    } else {
      this.users.update(users =>
        users.map(user => (user.id === change.id ? { ...user, active: !user.active } : user))
      );
    }
  }

  private sessionEmail(): string | null {
    try {
      const raw = globalThis.sessionStorage?.getItem(AUTH_USER_KEY);
      const correo = raw ? (JSON.parse(raw) as { correo?: unknown }).correo : null;
      return typeof correo === 'string' && correo ? correo : null;
    } catch {
      return null;
    }
  }

  private errorMessage(error: unknown): string {
    if (error instanceof HttpErrorResponse) {
      if (error.status === 401) return 'Contraseña incorrecta.';
      if (error.status === 0) return 'No se pudo conectar con el servidor.';
    }
    return 'No se pudo verificar la contraseña. Inténtalo de nuevo.';
  }
}
