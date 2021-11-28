import { Component } from '@angular/core';
import { METADATA } from '../metadata.const';

@Component({
  selector: 'cube-trainer-privacy-policy',
  templateUrl: './privacy-policy.component.html',
})
export class PrivacyPolicyComponent {
  get consentCookieKey() {
    return METADATA.consentCookieKey;
  }
}
