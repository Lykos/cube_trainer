import { Injectable } from '@angular/core';
import { TrainingCase } from './training-case.model';
import { TrainingSession } from './training-session.model';
import { Observable, from } from 'rxjs';
import { map } from 'rxjs/operators';
import { SamplerFactory } from './sampler-factory.service';
import { Sample } from '@utils/sampling';
import { SamplingStateService } from './sampling-state.service';
import { Instant } from '@utils/instant';
import { Alg } from 'cubing/alg';
import { randomScrambleForEvent } from 'cubing/scramble';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly samplerFactory: SamplerFactory,
              private readonly samplingStateService: SamplingStateService) {}

  randomScramble(now: Instant, trainingSession: TrainingSession): Observable<Alg> {
    return from(randomScrambleForEvent(this.cubeEvent(trainingSession)));
  }

  randomCase(now: Instant, trainingSession: TrainingSession): Observable<Sample<TrainingCase>> {    
    const sampler = this.samplerFactory.sampler(trainingSession);
    return this.samplingStateService.samplingState(now, trainingSession).pipe(
      map(state => sampler.sample(state)),
    );
  }

  private cubeEvent(trainingSession: TrainingSession) {
    const n = trainingSession.cubeSize;
    if (!n) {
      throw new Error('Cube size needs to be defined to determine the cube event.');
    }
    if (n >= 3 && n <= 5) {
      return `${n}${n}${n}bf`
    } else {
      return `${n}${n}${n}"`
    }
  }
}
