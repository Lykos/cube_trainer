import { CookieService } from 'ngx-cookie-service';
import { Injectable } from '@angular/core';
import { METADATA } from '../footer/metadata.const';

@Injectable({
  providedIn: 'root',
})
export class CookieConsentService {
  constructor(private readonly cookieService: CookieService) {}

  turnOnConsent() {
    this.cookieService.set(METADATA.consentCookieKey, 'true');
  }
}
