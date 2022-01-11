import { HostListener, Component, Input } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { overrideAlgClick } from '@store/training-sessions.actions';
import { showHint } from '@store/trainer.actions';
import { TrainingCase } from '../training-case.model';
import { Store } from '@ngrx/store';
import { selectHintActive } from '@store/trainer.selectors';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-hint',
  templateUrl: './hint.component.html',
  styleUrls: ['./hint.component.css']
})
export class HintComponent {
  @Input()
  trainingCase?: TrainingCase;

  @Input()
  trainingSession?: TrainingSession;

  active$: Observable<{ value: boolean }>;

  constructor(private readonly store: Store) {
    this.active$ = this.store.select(selectHintActive).pipe(map(value => ({ value })));
  }

  get alg() {
    return this.trainingCase?.alg;
  }

  onHint() {
    this.store.dispatch(showHint({ trainingSessionId: this.trainingSession!.id }));
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h') {
      this.onHint();
      return;
    }
  }

  onOverride() {
    this.trainingSession && this.trainingCase && this.store.dispatch(overrideAlgClick({ trainingSession: this.trainingSession, trainingCase: this.trainingCase }));
  }
}
