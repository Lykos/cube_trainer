import { HostListener, Component, Input } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { overrideAlgClick } from '@store/training-sessions.actions';
import { showHint } from '@store/trainer.actions';
import { TrainingCase } from '../training-case.model';
import { Store } from '@ngrx/store';

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

  @Input()
  active = false;

  constructor(private readonly store: Store) {}

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
