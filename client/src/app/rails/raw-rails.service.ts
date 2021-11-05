// @ts-ignore
import Rails from '@rails/ujs';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class RawRailsService {
  ajax<X>(request: any) {
    Rails.ajax(request);
  }
}
