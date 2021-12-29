import { HostListener, Component, Input, Output, EventEmitter } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { overrideAlgClick } from '@store/training-sessions.actions';
import { Case } from '../case.model';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-hint',
  templateUrl: './hint.component.html',
  styleUrls: ['./hint.component.css']
})
export class HintComponent {
  @Input()
  casee?: Case;

  @Input()
  trainingSession?: TrainingSession;

  @Input()
  active = false;

  @Output()
  activeChange = new EventEmitter<boolean>();

  constructor(private readonly store: Store) {}

  get alg() {
    return this.casee?.alg;
  }

  onHint() {
    this.active = true;
    this.activeChange.emit(true);
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h') {
      this.onHint();
      return;
    }
  }

  onOverride() {
    this.trainingSession && this.casee && this.store.dispatch(overrideAlgClick({ trainingSession: this.trainingSession, casee: this.casee }));
  }
}
