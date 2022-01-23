import { Injectable } from '@angular/core';
import { TrainingCase } from './training-case.model';
import { TrainingSession } from './training-session.model';
import { GeneratorType } from './generator-type.model';
import { ScrambleOrSample, scramble, sample } from './scramble-or-sample.model';
import { Result } from './result.model';
import { Observable, from, of, throwError } from 'rxjs';
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

  randomScrambleOrSample(now: Instant, trainingSession: TrainingSession, results: readonly Result[]): Observable<ScrambleOrSample> {
    const generatorType = trainingSession.generatorType;
    switch (generatorType) {
      case GeneratorType.Scramble:
        return this.randomScramble(now, trainingSession).pipe(map(scramble));
      case GeneratorType.Case:
        return this.randomTrainingCase(now, trainingSession, results).pipe(map(sample));
      default:
        throw new Error(`Unknown generator type ${generatorType}`);
    }
  }
  
  randomScramble(now: Instant, trainingSession: TrainingSession): Observable<Alg> {
    return from(randomScrambleForEvent(this.cubeEvent(trainingSession)));
  }

  randomTrainingCase(now: Instant, trainingSession: TrainingSession, results: readonly Result[]): Observable<Sample<TrainingCase>> {
    if (trainingSession.trainingCases.length === 0) {
      return throwError(new Error('No cases configured. This can happen for training sessions with no algs and a configuration to avoid cases without algs. Please reconfigure your session.'));
    }
    const sampler = this.samplerFactory.sampler(trainingSession);
    const samplingState = this.samplingStateService.samplingState(now, trainingSession, results);
    return of(sampler.sample(samplingState));
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
