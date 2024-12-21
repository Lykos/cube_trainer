import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';
import { GoogleAnalyticsReferenceComponent } from '../google-analytics-reference/google-analytics-reference.component';

@Component({
  selector: 'cube-trainer-cookie-policy',
  templateUrl: './cookie-policy.component.html',
  imports: [GoogleAnalyticsReferenceComponent],
})
export class CookiePolicyComponent {
  get consentCookieKey() {
    return METADATA.consentCookieKey;
  }
}
