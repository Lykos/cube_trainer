import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';

@Component({
  selector: 'cube-trainer-privacy-policy',
  templateUrl: './privacy-policy.component.html',
  standalone: false,
})
export class PrivacyPolicyComponent {
  get consentCookieKey() {
    return METADATA.consentCookieKey;
  }
}
