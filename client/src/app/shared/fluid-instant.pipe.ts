import { Pipe, PipeTransform, Inject, LOCALE_ID } from '@angular/core';
import { Instant } from '@utils/instant';
import { formatDate } from '@angular/common';

@Pipe({
  name: 'fluidInstant'
})
export class FluidInstantPipe implements PipeTransform {
  constructor(@Inject(LOCALE_ID) private readonly locale: string) {}

  transform(instant: Instant, now: Instant) {
    if (instant.sameDay(now)) {
      return formatDate(instant.toDate(), 'shortTime', this.locale);
    } else {
      return formatDate(instant.toDate(), 'shortDate', this.locale);
    }
  }
}
