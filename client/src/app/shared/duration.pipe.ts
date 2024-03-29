import { Pipe, PipeTransform } from '@angular/core';
import { Duration } from '@utils/duration';

@Pipe({
  name: 'duration'
})
export class DurationPipe implements PipeTransform {
  transform(duration: Duration) {
    return duration.toString();
  }
}
