import { Injectable } from '@angular/core';
import { Actions, ofType, concatLatestFrom, createEffect } from '@ngrx/effects';
import { of, forkJoin } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, switchMap, filter, flatMap, map, tap, mapTo } from 'rxjs/operators';
import { millis } from '@utils/duration';
import { isRunning } from '@store/trainer.state';
import {
  initialLoadSelected,
  initialLoad,
  initialLoadResults,
  initialLoadResultsNop,
  initialLoadResultsSuccess,
  initialLoadResultsFailure,
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
  loadNextCaseSuccess,
  loadNextCaseFailure,
  startStopwatch,
  stopAndStartStopwatch,
  stopAndPauseStopwatch,
  stopStopwatch,
  stopStopwatchSuccess,
  stopStopwatchFailure,
} from '@store/trainer.actions';
import { loadOne } from '@store/training-sessions.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { ResultsService } from '@training/results.service';
import { NewResult } from '@training/new-result.model';
import { TrainerService } from '@training/trainer.service';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '@utils/optional';
import { now, fromUnixMillis } from '@utils/instant';
import { selectTrainingSessionAndResultsById, selectIsInitialLoadNecessaryById, selectNextCaseAndHintActiveById, selectStopwatchState, selectStartAfterLoading } from '@store/trainer.selectors';
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
      switchMap(action => { console.log('initial loading results after initial load'); return of(
        initialLoadResults({ trainingSessionId: action.trainingSessionId }),
        loadOne({ trainingSessionId: action.trainingSessionId }),
      )}),
    )
  );

  initialLoadResults$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoadResults),
      concatLatestFrom(() => this.store.select(selectIsInitialLoadNecessaryById)),
      switchMap(([action, initialLoadNecessaryById]) => {
        if (!initialLoadNecessaryById.get(action.trainingSessionId)) {
          // TODO: If it's recent, return this.
          of(initialLoadResultsNop({ trainingSessionId: action.trainingSessionId }));
        }
        return this.resultsService.list(action.trainingSessionId).pipe(
          map(results => initialLoadResultsSuccess({ trainingSessionId: action.trainingSessionId, results })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'results',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadResultsFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        );
      })
    )
  );

  initialLoadResultsSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoadResultsSuccess),
      map(action => { console.log('load next case after initial load results'); return loadNextCase({ trainingSessionId: action.trainingSessionId }) }),
    )
  );

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
      map(([action, trainingSessionId]) => { console.log('load selected next case'); return loadNextCase({ trainingSessionId }); }),
    )
  );

  loadNextCase$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadNextCase),
      concatLatestFrom(() => this.store.select(selectTrainingSessionAndResultsById).pipe(filter(hasValue), map(forceValue))),
      switchMap(([action, lolMap]) => {
        console.log('loading next case');
        const { trainingSession, results } = lolMap.get(action.trainingSessionId)!;
        return this.trainerService.randomScrambleOrSample(now(), trainingSession, results).pipe(
          map(nextCase => loadNextCaseSuccess({ trainingSessionId: action.trainingSessionId, nextCase })),
          catchError(httpResponseError => {
            const context = { action: 'selecting', subject: 'next scramble or sample' };
            const error = parseBackendActionError(context, httpResponseError);
            return of(loadNextCaseFailure({ trainingSessionId: action.trainingSessionId, error }));
          })
        )
      })
    )
  );


  loadNextCaseSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadNextCaseSuccess),
      concatLatestFrom(() => this.store.select(selectStartAfterLoading)),
      switchMap(([action, startAfterLoading]) => {
        if (!startAfterLoading) {
          return of();
        }
        return of(startStopwatch({ trainingSessionId: action.trainingSessionId, startUnixMillis: now().toUnixMillis() }));
      }),
    )
  );

  stopAndXXXStopwatch$ = createEffect(() =>
    this.actions$.pipe(
      ofType(stopAndStartStopwatch, stopAndPauseStopwatch),
      map(action => stopStopwatch({ trainingSessionId: action.trainingSessionId, stopUnixMillis: action.stopUnixMillis })),
    )
  );

  stopStopwatch$ = createEffect(() =>
    this.actions$.pipe(
      ofType(stopStopwatch),
      concatLatestFrom(() => this.store.select(selectStopwatchState)),
      map(([action, state]) => {
        if (!isRunning(state)) {
          const context = { action: 'stopping', subject: 'stopwatch' };
          const error = parseBackendActionError(context, new Error('Cannot stop a stopwatch that is not running'));
          return stopStopwatchFailure({ trainingSessionId: action.trainingSessionId, error });
        }
        const start = fromUnixMillis(state.startUnixMillis);
        const stop = fromUnixMillis(action.stopUnixMillis);
        const duration = stop.minusInstant(start);
        return stopStopwatchSuccess({ trainingSessionId: action.trainingSessionId, durationMillis: duration.toMillis() })
      }),
    ),
  );

  stopStopwatchSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(stopStopwatchSuccess),
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
        console.log('load next case after stopwatch success');
        return of(
          create({ trainingSessionId: action.trainingSessionId, newResult }),
          loadNextCase({ trainingSessionId: action.trainingSessionId })
        );
      }),
    )
  );

  failure$ = createEffect(() =>
    this.actions$.pipe(
      // Failure for initialLoadResults has no here effect,
      // it shows a message at the component where the results are rendered.
      ofType(createFailure, destroyFailure, markDnfFailure, loadNextCaseFailure, stopStopwatchFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );
}
