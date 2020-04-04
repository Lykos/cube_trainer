import { Pipe, PipeTransform } from '@angular/core';
import { Instant } from '../utils/instant';

@Pipe({
  name: 'instant'
})
export class InstantPipe implements PipeTransform {
  transform(instant: Instant) {
    return instant.toString();
  }
}
