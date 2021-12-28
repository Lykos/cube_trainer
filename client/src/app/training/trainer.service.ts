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

  private casesCache(modeId: number) {
    const cache = this.casesCacheMap.get(modeId);
    if (cache) {
      return cache;
    }
    const newCache = new QueueCache<Case>(cacheSize, (cachedItems: Case[]) => this.randomCase(modeId, cachedItems));
    this.casesCacheMap.set(modeId, newCache);
    return newCache;
  }

  nextCaseWithCache(modeId: number): Observable<Case> {
    return this.casesCache(modeId).next();
  }

  prewarmCasesCache(modeId: number) {
    this.casesCache(modeId);
  }

  private randomCase(modeId: number, cachedCases: Case[] = []): Observable<Case> {
    const cachedCaseKeys = cachedCases.map(i => i.key);
    return this.rails.get<Case>(`/trainer/${modeId}/random_case`, {cachedCaseKeys}).pipe(map(parseCase));
  }
}
