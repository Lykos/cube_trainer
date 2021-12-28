import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of, forkJoin } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap, mapTo } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure } from '../state/results.actions';
import { ResultsService } from '../trainer/results.service';
 
@Injectable()
export class ResultsEffects {
  constructor(
    private actions$: Actions,
    private readonly resultsService: ResultsService,
    private readonly snackBar: MatSnackBar,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.resultsService.list(action.modeId).pipe(
          map(results => initialLoadSuccess({ modeId: action.modeId, results })),
          catchError(error => of(initialLoadFailure({ modeId: action.modeId, error })))
        )
      )
    )
  );

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
          this.resultsService.create(action.modeId, action.casee, action.partialResult).pipe(
          map(result => createSuccess({ modeId: action.modeId, casee: action.casee, partialResult: action.partialResult, result })),
          catchError(error => of(createFailure({ modeId: action.modeId, error })))
        )
      )
    )
  );

  destroy$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroy),
      exhaustMap(action => {
        const observables = action.results.map(result => this.resultsService.destroy(action.modeId, result.id));
        return forkJoin(observables).pipe(
          mapTo(destroySuccess({ modeId: action.modeId, results: action.results })),
          catchError(error => of(destroyFailure({ modeId: action.modeId, error }))),
        )
      })
    )
  );

  destroySuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroySuccess),
      tap(action => {
	this.snackBar.open(`Deleted ${action.results.length} results.`, 'Close');
      }),
    ),
    { dispatch: false }
  );

  markDnf$ = createEffect(() =>
    this.actions$.pipe(
      ofType(markDnf),
      exhaustMap(action => {
        const observables = action.results.map(result => this.resultsService.markDnf(action.modeId, result.id));
        return forkJoin(observables).pipe(
          map(results => markDnfSuccess({ modeId: action.modeId, results })),
          catchError(error => of(markDnfFailure({ modeId: action.modeId, error }))),
        )
      })
    )
  );

  markDnfSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(markDnfSuccess),
      tap(action => {
	this.snackBar.open(`Marked ${action.results.length} results as DNF.`, 'Close');
      }),
    ),
    { dispatch: false }
  );
}
