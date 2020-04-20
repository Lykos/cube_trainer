import { CollectionViewer, DataSource } from '@angular/cdk/collections';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { map, catchError, finalize } from 'rxjs/operators';
import { Stat } from './stat';
import { StatPart } from './stat-part';
import { StatsService } from './stats.service';

export class StatsDataSource implements DataSource<StatPart> {

  private statPartsSubject = new BehaviorSubject<StatPart[]>([]);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  public loading$ = this.loadingSubject.asObservable();

  constructor(private readonly statsService: StatsService) {}

  get data() {
    return this.statPartsSubject.value;
  }

  connect(collectionViewer: CollectionViewer): Observable<StatPart[]> {
    return this.statPartsSubject.asObservable();
  }

  disconnect(collectionViewer: CollectionViewer): void {
    this.statPartsSubject.complete();
    this.loadingSubject.complete();
  }

  loadStats(modeId: number) {
    this.loadingSubject.next(true);
    this.statsService.list(modeId).pipe(
      map((stats: Stat[]) => {
	const statParts: StatPart[] = [];
	stats.forEach(stat => stat.parts.forEach(statPart => statParts.push(statPart)));
	return statParts;
      }),
      catchError(() => of([])),
      finalize(() => this.loadingSubject.next(false))
    )
      .subscribe((statParts: StatPart[]) => {
	return this.statPartsSubject.next(statParts);
      });
  }    
}
