import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Case } from './case.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { QueueCache } from '@utils/queue-cache';

function parseCase(casee: any) {
  return {
    key: casee.case_key,
    name: casee.case_name,
    alg: casee.alg,
    setup: casee.setup
  };
}

// This is intentionally very small.
// Having a big cache size makes the adaptive sampling in the backend worse.
// We just take 2 to get rid of latencies.
const cacheSize = 2;

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  private readonly casesCacheMap = new Map<number, QueueCache<Case>>();

  private casesCache(trainingSessionId: number) {
    const cache = this.casesCacheMap.get(trainingSessionId);
    if (cache) {
      return cache;
    }
    const newCache = new QueueCache<Case>(cacheSize, (cachedItems: Case[]) => this.randomCase(trainingSessionId, cachedItems));
    this.casesCacheMap.set(trainingSessionId, newCache);
    return newCache;
  }

  nextCaseWithCache(trainingSessionId: number): Observable<Case> {
    return this.casesCache(trainingSessionId).next();
  }

  prewarmCasesCache(trainingSessionId: number) {
    this.casesCache(trainingSessionId);
  }

  private randomCase(trainingSessionId: number, cachedCases: Case[] = []): Observable<Case> {
    const cachedCaseKeys = cachedCases.map(i => i.key);
    return this.rails.get<Case>(`/trainer/${trainingSessionId}/random_case`, {cachedCaseKeys}).pipe(map(parseCase));
  }
}
