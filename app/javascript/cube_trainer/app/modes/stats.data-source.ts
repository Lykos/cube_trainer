import { CollectionViewer, DataSource } from '@angular/cdk/collections';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';
import { Stat } from './stat';
import { StatsService } from './stats.service';

export class StatsDataSource implements DataSource<Stat> {

  private statsSubject = new BehaviorSubject<Stat[]>([]);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  public loading$ = this.loadingSubject.asObservable();

  constructor(private readonly statsService: StatsService) {}

  get data() {
    return this.statsSubject.value;
  }

  connect(collectionViewer: CollectionViewer): Observable<Stat[]> {
    return this.statsSubject.asObservable();
  }

  disconnect(collectionViewer: CollectionViewer): void {
    this.statsSubject.complete();
    this.loadingSubject.complete();
  }

  loadStats(modeId: number) {
    this.loadingSubject.next(true);
    this.statsService.list(modeId).pipe(
      catchError(() => of([])),
      finalize(() => this.loadingSubject.next(false))
    )
      .subscribe((stats: Stat[]) => {
	return this.statsSubject.next(stats);
      });
  }    
}
