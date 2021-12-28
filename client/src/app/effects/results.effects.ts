import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of, forkJoin } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap, mapTo } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure } from '@store/results.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { ResultsService } from '@training/results.service';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';

@Injectable()
export class ResultsEffects {
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
        this.resultsService.list(action.modeId).pipe(
          map(results => initialLoadSuccess({ modeId: action.modeId, results })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'results',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ modeId: action.modeId, error }));
          })
        )
      )
    )
  );

  // Failure for initialLoad has no effect, it shows a message at the component where the modes are rendered.

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
          this.resultsService.create(action.modeId, action.casee, action.partialResult).pipe(
          map(result => createSuccess({ modeId: action.modeId, casee: action.casee, partialResult: action.partialResult, result })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating result',
              subject: `${action.casee.name}`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(createFailure({ modeId: action.modeId, error }));
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
        const observables = action.results.map(result => this.resultsService.destroy(action.modeId, result.id));
        return forkJoin(observables).pipe(
          mapTo(destroySuccess({ modeId: action.modeId, results: action.results })),
          catchError(httpResponseError => {
            const context = {
              action: 'deleting',
              subject: `${action.results.length} results`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(destroyFailure({ modeId: action.modeId, error }));
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
          catchError(httpResponseError => {
            const context = {
              action: 'marking as DNF',
              subject: `${action.results.length} results`,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(markDnfFailure({ modeId: action.modeId, error }));
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
	this.snackBar.open(`Marked ${action.results.length} results as DNF.`, 'Close');
      }),
    ),
    { dispatch: false }
  );
}
