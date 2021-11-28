import { BrowserModule } from '@angular/platform-browser';
import { CookieService } from 'ngx-cookie-service';
import { CookieConsentService } from './cookie-consent.service';
import { NgModule } from '@angular/core';

@NgModule({
  imports: [BrowserModule],
  providers: [
    CookieService,
    CookieConsentService,
  ],
})
export class SharedModule {}
