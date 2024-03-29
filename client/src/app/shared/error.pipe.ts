import { Pipe, PipeTransform } from '@angular/core';
import { OrError, errorOrElse } from './or-error.type';

@Pipe({
  name: 'error'
})
export class ErrorPipe implements PipeTransform {
  transform<X>(valueOrError: OrError<X>): any {
    return errorOrElse(valueOrError, undefined);
  }
}
