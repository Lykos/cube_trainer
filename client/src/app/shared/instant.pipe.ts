import { Pipe, PipeTransform, Inject, LOCALE_ID } from '@angular/core';
import { Instant } from '@utils/instant';
import { formatDate } from '@angular/common';

@Pipe({
  name: 'instant',
  standalone: false,
})
export class InstantPipe implements PipeTransform {
  constructor(@Inject(LOCALE_ID) private readonly locale: string) {}

  transform(instant: Instant) {
    return formatDate(instant.toDate(), 'short', this.locale);
  }
}
