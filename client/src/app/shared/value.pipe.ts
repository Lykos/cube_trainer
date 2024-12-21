import { Pipe, PipeTransform } from '@angular/core';
import { OrError, valueOrElse } from './or-error.type';

@Pipe({
  name: 'value',
  standalone: false,
})
export class ValuePipe implements PipeTransform {
  transform<X>(valueOrError: OrError<X>): X | undefined {
    return valueOrElse(valueOrError, undefined);
  }
}
