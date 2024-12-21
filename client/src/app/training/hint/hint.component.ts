import { HostListener, Component, Input } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { overrideAlgClick, setAlgClick } from '@store/training-sessions.actions';
import { showHint } from '@store/trainer.actions';
import { TrainingCase } from '../training-case.model';
import { Store } from '@ngrx/store';
import { selectHintActive } from '@store/trainer.selectors';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { SharedModule } from '@shared/shared.module';
import { NgClass } from '@angular/common';

@Component({
  selector: 'cube-trainer-hint',
  templateUrl: './hint.component.html',
  styleUrls: ['./hint.component.css'],
  imports: [NgClass, SharedModule],
})
export class HintComponent {
  @Input()
  trainingCase?: TrainingCase | null;

  @Input()
  trainingSession?: TrainingSession;

  active$: Observable<{ value: boolean }>;

  constructor(private readonly store: Store) {
    this.active$ = this.store.select(selectHintActive).pipe(map(value => ({ value })));
  }

  get alg() {
    return this.trainingCase?.alg;
  }

  get algSource() {
    return this.trainingCase?.algSource?.tag;
  }

  get algSourceClass() {
    return this.algSource || '';
  }

  get tooltip() {
    switch (this.algSource) {
      case 'original': return 'This alg comes unchanged from the source alg sheet.';
      case 'fixed': return 'This alg comes from the source alg sheet, but the original had a mistake (e.g. wrong direction) and it was fixed here.';
      case 'inferred': return 'This alg was inferred from a related alg (usually the inverse).';
      case 'overridden': return 'This alg has been previously overridden by you.';
      default: return '';
    }
  }

  onHint(trainingSession: TrainingSession) {
    this.store.dispatch(showHint({ trainingSessionId: trainingSession.id }));
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (this.trainingSession && event.key === 'h') {
      this.onHint(this.trainingSession);
      return;
    }
  }

  onOverride() {
    this.trainingSession && this.trainingCase && this.store.dispatch(overrideAlgClick({ trainingSession: this.trainingSession, trainingCase: this.trainingCase }));
  }

  onSet() {
    this.trainingSession && this.trainingCase && this.store.dispatch(setAlgClick({ trainingSession: this.trainingSession, trainingCase: this.trainingCase }));
  }
}
