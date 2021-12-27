import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatRippleModule } from '@angular/material/core';
import { MatButtonModule } from '@angular/material/button';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule } from '@angular/material/dialog';
import { CookieService } from 'ngx-cookie-service';
import { CookieConsentService } from './cookie-consent.service';
import { OrErrorPipe } from './or-error.pipe';
import { ValuePipe } from './value.pipe';
import { ErrorPipe } from './error.pipe';
import { NgModule } from '@angular/core';
import { BackendActionErrorDialogComponent } from './backend-action-error-dialog/backend-action-error-dialog.component';

@NgModule({
  declarations: [
    OrErrorPipe,
    ValuePipe,
    ErrorPipe,
    BackendActionErrorDialogComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    MatRippleModule,
    MatButtonModule,
    MatDialogModule,
    MatTooltipModule,
  ],
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
