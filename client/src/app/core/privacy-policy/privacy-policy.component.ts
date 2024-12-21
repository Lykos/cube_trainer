import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';
import { GoogleAnalyticsReferenceComponent } from '../google-analytics-reference/google-analytics-reference.component';
import { ContactContentComponent } from '../contact-content/contact-content.component';

import { DatePipe } from '@angular/common';

@Component({
  selector: 'cube-trainer-privacy-policy',
  templateUrl: './privacy-policy.component.html',
  imports: [GoogleAnalyticsReferenceComponent, ContactContentComponent, DatePipe],
})
export class PrivacyPolicyComponent {
  get consentCookieKey() {
    return METADATA.consentCookieKey;
  }
}
