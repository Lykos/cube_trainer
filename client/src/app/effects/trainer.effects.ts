import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of, forkJoin } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap, mapTo } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure } from '@store/trainer.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { ResultsService } from '@training/results.service';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';

@Injectable()
export class TrainerEffects {
  constructor(
    private actions$: Actions,
    private readonly resultsService: ResultsService,
    private readonly dialog: MatDialog,
    private readonly snackBar: MatSnackBar,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.resultsService.list(action.trainingSessionId).pipe(
          map(results => initialLoadSuccess({ trainingSessionId: action.trainingSessionId, results })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'results',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      )
    )
  );

  // Failure for initialLoad has no effect, it shows a message at the component where the results are rendered.

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
          this.resultsService.create(action.trainingSessionId, action.newResult).pipe(
          map(result => createSuccess({ trainingSessionId: action.trainingSessionId, result })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating result',
              subject: `${action.newResult.caseName}`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(createFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      )
    )
  );

  createFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  destroy$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroy),
      exhaustMap(action => {
        const observables = action.resultIds.map(resultId => this.resultsService.destroy(action.trainingSessionId, resultId));
        return forkJoin(observables).pipe(
          mapTo(destroySuccess({ trainingSessionId: action.trainingSessionId, resultIds: action.resultIds })),
          catchError(httpResponseError => {
            const context = {
              action: 'deleting',
              subject: `${action.resultIds.length} results`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(destroyFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      })
    )
  );

  destroyFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroyFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  destroySuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroySuccess),
      tap(action => {
	this.snackBar.open(`Deleted ${action.resultIds.length} results.`, 'Close');
      }),
    ),
    { dispatch: false }
  );

  markDnf$ = createEffect(() =>
    this.actions$.pipe(
      ofType(markDnf),
      exhaustMap(action => {
        const observables = action.resultIds.map(resultId => this.resultsService.markDnf(action.trainingSessionId, resultId));
        return forkJoin(observables).pipe(
          map(results => markDnfSuccess({ trainingSessionId: action.trainingSessionId, resultIds: results.map(r => r.id) })),
          catchError(httpResponseError => {
            const context = {
              action: 'marking as DNF',
              subject: `${action.resultIds.length} results`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(markDnfFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      })
    )
  );

  markDnfFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(markDnfFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  markDnfSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(markDnfSuccess),
      tap(action => {
	this.snackBar.open(`Marked ${action.resultIds.length} results as DNF.`, 'Close');
      }),
    ),
    { dispatch: false }
  );
}
