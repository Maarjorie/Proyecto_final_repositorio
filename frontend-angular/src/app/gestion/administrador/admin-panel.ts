
/*

import { Component, inject, output, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RepositorioService } from '../../compartido/repositorio.service';
import { Screen, UserRole } from '../../compartido/modelos';

@Component({
  selector: 'app-admin-panel',
  imports: [FormsModule],
  templateUrl: './admin-panel.html',
  styleUrls: ['../gestion-base.css', './admin-panel.css'],
})
export class AdminPanel {
  readonly repo = inject(RepositorioService);
  readonly navegar = output<Screen>();

  readonly roles: UserRole[] = ['Administrador', 'Supervisor', 'Lector'];
  readonly newUsername = signal('');
  readonly newUserName = signal('');

  addUser(): void {
    if (this.repo.addUser(this.newUsername(), this.newUserName())) {
      this.newUsername.set('');
      this.newUserName.set('');
    }
  }
}

*/