import { Component } from '@angular/core';
import { METADATA } from '../metadata.const';

@Component({
  selector: 'cube-trainer-cookie-policy',
  templateUrl: './cookie-policy.component.html',
})
export class CookiePolicyComponent {
  get consentCookieKey() {
    return METADATA.consentCookieKey;
  }
}
