import { createSelector } from '@ngrx/store';
import { getSelectors } from '@ngrx/router-store';
import { ofNull } from '@utils/optional';
 
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

export const selectSelectedTrainingSessionId = createSelector(
  selectRouteParam('trainingSessionId'),
  id => ofNull(id === undefined ? undefined : +id),
);
