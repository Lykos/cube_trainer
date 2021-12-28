import * as Rails from 'rails/ujs';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class RawRailsService {
  ajax(options: Rails.AjaxOptions) {
    Rails.ajax(options);
  }
}
