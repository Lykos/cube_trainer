import { Pipe, PipeTransform } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';
import { OrError, value, error } from './or-error.type';

@Pipe({
  name: 'orerror'
})
export class OrErrorPipe implements PipeTransform {
  transform<X>(observable: Observable<X>): Observable<OrError<X>> {
    return observable.pipe(
      map(val => value(val)),
      catchError(err => of(error(err))),
    );
  }
}
