import { Injectable } from '@angular/core';
import { Actions, ofType, concatLatestFrom, createEffect } from '@ngrx/effects';
import { of, forkJoin } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, switchMap, filter, flatMap, map, tap, mapTo } from 'rxjs/operators';
import { millis } from '@utils/duration';
import {
  initialLoadSelected,
  initialLoad,
  initialLoadNop,
  initialLoadSuccess,
  initialLoadFailure,
  create,
  createSuccess,
  createFailure,
  destroy,
  destroySuccess,
  destroyFailure,
  markDnf,
  markDnfSuccess,
  markDnfFailure,
  loadSelectedNextCase,
  loadNextCase,
  loadNextCaseNop,
  loadNextCaseSuccess,
  loadNextCaseFailure,
  stopStopwatch,
} from '@store/trainer.actions';
import { initialLoad as trainingSessionsInitialLoad } from '@store/training-sessions.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { ResultsService } from '@training/results.service';
import { NewResult } from '@training/new-result.model';
import { TrainerService } from '@training/trainer.service';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '@utils/optional';
import { now } from '@utils/instant';
import { selectTrainingSessionAndResultsAndNextCaseNecessaryById, selectIsInitialLoadNecessaryById, selectNextCaseAndHintActiveById } from '@store/trainer.selectors';
import { selectSelectedTrainingSessionId } from '@store/router.selectors';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';

function caseName(scrambleOrSample: ScrambleOrSample) {
  switch (scrambleOrSample.tag) {
    case 'scramble':
      return scrambleOrSample.scramble.toString();
    case 'sample':
      return scrambleOrSample.sample.item.caseName;
  }
}

function caseKey(scrambleOrSample: ScrambleOrSample) {
  switch (scrambleOrSample.tag) {
    case 'scramble':
      return scrambleOrSample.scramble.toString();
    case 'sample':
      return scrambleOrSample.sample.item.caseKey;
  }
}

@Injectable()
export class TrainerEffects {
  constructor(
    private readonly actions$: Actions,
    private readonly store: Store,
    private readonly resultsService: ResultsService,
    private readonly trainerService: TrainerService,
    private readonly dialog: MatDialog,
    private readonly snackBar: MatSnackBar,
  ) {}

  initialLoadSelected$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoadSelected),
      concatLatestFrom(() => this.store.select(selectSelectedTrainingSessionId).pipe(filter(hasValue), map(forceValue))),
      map(([action, trainingSessionId]) => initialLoad({ trainingSessionId })),
    )
  );

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      concatLatestFrom(() => this.store.select(selectIsInitialLoadNecessaryById)),
      switchMap(([action, initialLoadNecessaryById]) => {
        if (!initialLoadNecessaryById.get(action.trainingSessionId)) {
          of(initialLoadNop({ trainingSessionId: action.trainingSessionId }));
        }
        return this.resultsService.list(action.trainingSessionId).pipe(
          map(results => initialLoadSuccess({ trainingSessionId: action.trainingSessionId, results })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'results',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        );
      })
    )
  );

  initialLoadSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoadSuccess),
      flatMap(action => of(
        trainingSessionsInitialLoad(),
        loadNextCase({ trainingSessionId: action.trainingSessionId })
      )),
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

  loadSelectedNextCase$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadSelectedNextCase),
      concatLatestFrom(() => this.store.select(selectSelectedTrainingSessionId).pipe(filter(hasValue), map(forceValue))),
      map(([action, trainingSessionId]) => loadNextCase({ trainingSessionId })),
    )
  );

  loadNextCase$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadNextCase),
      concatLatestFrom(() => this.store.select(selectTrainingSessionAndResultsAndNextCaseNecessaryById).pipe(filter(hasValue), map(forceValue))),
      switchMap(([action, lolMap]) => {
        const { trainingSession, results, nextCaseNecessary } = lolMap.get(action.trainingSessionId)!;
        if (!nextCaseNecessary) {
          return of(loadNextCaseNop({ trainingSessionId: action.trainingSessionId }));
        }
        return this.trainerService.randomScrambleOrSample(now(), trainingSession, results).pipe(
          map(nextCase => loadNextCaseSuccess({ trainingSessionId: action.trainingSessionId, nextCase })),
          catchError(httpResponseError => {
            const context = {
              action: 'selecting',
              subject: 'next scramble or sample',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(loadNextCaseFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      })
    )
  );

  loadNextCaseFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadNextCaseFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  stopStopwatch$ = createEffect(() =>
    this.actions$.pipe(
      ofType(stopStopwatch),
      concatLatestFrom(() => this.store.select(selectNextCaseAndHintActiveById)),
      flatMap(([action, lolMap]) => {
        const { nextCase, hintActive } = lolMap.get(action.trainingSessionId)!;
        const scrambleOrSample = forceValue(nextCase);
        const duration = millis(action.durationMillis);
        const newResult: NewResult = {
          caseKey: caseKey(scrambleOrSample),
          caseName: caseName(scrambleOrSample),
          numHints: hintActive ? 1 : 0,
          timeS: duration.toSeconds(),
          success: true,
        };
        return of(
          create({ trainingSessionId: action.trainingSessionId, newResult }),
          loadNextCase({ trainingSessionId: action.trainingSessionId })
        );
      }),
    )
  );
}
