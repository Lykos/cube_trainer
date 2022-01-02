import { Injectable } from '@angular/core';
import { TrainingCase } from './training-case.model';
import { TrainingSession } from './training-session.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { SamplerFactory } from './sampler-factory.service';
import { SamplingStateService } from './sampling-state.service';
import { Instant } from '@utils/instant';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly samplerFactory: SamplerFactory,
              private readonly samplingStateService: SamplingStateService) {}

  randomCase(now: Instant, trainingSession: TrainingSession): Observable<TrainingCase> {
    const sampler = this.samplerFactory.sampler(trainingSession);
    return this.samplingStateService.samplingState(now, trainingSession).pipe(
      map(state => sampler.sample(state)),
    );
  }
}
