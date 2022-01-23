import { Observable } from 'rxjs'
import { Optional, ifPresent } from '@utils/optional'

export function filterPresent() {
  return function<T>(source: Observable<Optional<T>>): Observable<T> {
    return new Observable(subscriber => {
      return source.subscribe({
	next(optional: Optional<T>) {
	  ifPresent(optional, value => {
	    subscriber.next(value);
	  });
	},

	error(error) {
	  subscriber.error(error);
	},

	complete() {
	  subscriber.complete();
	},
      });
    });
  }
}
