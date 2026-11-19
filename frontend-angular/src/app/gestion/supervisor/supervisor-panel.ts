
/*
import { Component, inject, output, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RepositorioService } from '../../compartido/repositorio.service';
import { ReviewStatus, Screen } from '../../compartido/modelos';

@Component({
  selector: 'app-supervisor-panel',
  imports: [FormsModule],
  templateUrl: './supervisor-panel.html',
  styleUrls: ['../gestion-base.css', './supervisor-panel.css'],
})
export class SupervisorPanel {
  readonly repo = inject(RepositorioService);
  readonly navegar = output<Screen>();

  readonly reviewNotes = signal<Record<number, string>>({});
  readonly withdrawTarget = signal<number | null>(null);
  readonly withdrawReason = signal('');

  setReviewNote(deliveryId: number, note: string): void {
    this.reviewNotes.update((notes) => ({ ...notes, [deliveryId]: note }));
  }

  decidir(deliveryId: number, decision: ReviewStatus): void {
    const ok = this.repo.decideDelivery(deliveryId, decision, this.reviewNotes()[deliveryId] ?? '');
    if (ok) this.setReviewNote(deliveryId, '');
  }

  beginWithdrawal(workId: number): void {
    this.withdrawTarget.set(workId);
    this.withdrawReason.set('');
  }

  cancelWithdrawal(): void {
    this.withdrawTarget.set(null);
    this.withdrawReason.set('');
  }

  confirmWithdrawal(): void {
    const workId = this.withdrawTarget();
    if (!workId) return;
    if (this.repo.confirmWithdrawal(workId, this.withdrawReason())) this.cancelWithdrawal();
  }

  dateLabel(value: string): string {
    return new Intl.DateTimeFormat('es-SV', { dateStyle: 'short', timeStyle: 'short' }).format(new Date(value));
  }
}

*/