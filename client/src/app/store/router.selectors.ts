import { MemoizedSelector, createSelector } from '@ngrx/store';
import { getSelectors } from '@ngrx/router-store';
import { Optional, ofNull } from '@utils/optional';
 
export const {
  selectCurrentRoute, // select the current route
  selectFragment, // select the current route fragment
  selectQueryParams, // select the current route query params
  selectQueryParam, // factory function to select a query param
  selectRouteParams, // select the current route params
  selectRouteParam, // factory function to select a route param
  selectRouteData, // select the current route data
  selectUrl, // select the current url
} = getSelectors();

// For component tests, using a mock store allows us to conveniently override all selectors.
// But for integration tests, we want to use the actual store implementation.
// But we want to mock out the routing because getting routing to work in tests is a mess.
export const overrideSelectedTrainingSessionIdForTesting: { value: Optional<number> | undefined } = { value: undefined };

export const selectSelectedTrainingSessionId: MemoizedSelector<any, Optional<number>> = createSelector(
  selectRouteParam('trainingSessionId'),
  id => overrideSelectedTrainingSessionIdForTesting.value || ofNull(id === undefined ? undefined : +id),
);
