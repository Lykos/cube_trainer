import { BrowserModule } from '@angular/platform-browser';
import { CookieService } from 'ngx-cookie-service';
import { CookieConsentService } from './cookie-consent.service';
import { OrErrorPipe } from './or-error.pipe';
import { ValuePipe } from './value.pipe';
import { ErrorPipe } from './error.pipe';
import { NgModule } from '@angular/core';

@NgModule({
  declarations: [
    OrErrorPipe,
    ValuePipe,
    ErrorPipe,
  ],
  imports: [BrowserModule],
  providers: [
    CookieService,
    CookieConsentService,
  ],
  exports: [
    OrErrorPipe,
    ValuePipe,
    ErrorPipe,
  ],
})
export class SharedModule {}
