import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { TrainingSessionsService } from './training-sessions.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueTrainingSessionNameValidator implements AsyncValidator {
  constructor(private trainingSessionsService: TrainingSessionsService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.trainingSessionsService.isTrainingSessionNameTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueTrainingSessionName: true } : null)),
      catchError(() => of(null))
    );
  }
}
