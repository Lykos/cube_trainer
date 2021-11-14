import { NgModule } from '@angular/core';
import { FooterComponent } from './footer.component';
import { PrivacyPolicyComponent } from './privacy-policy.component';
import { TermsAndConditionsComponent } from './terms-and-conditions.component';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [
    FooterComponent,
    PrivacyPolicyComponent,
    TermsAndConditionsComponent,
  ],
  imports: [
    BrowserModule,
    MatToolbarModule,
    MatCardModule,
    BrowserAnimationsModule,
    MatButtonModule,
    RouterModule,
  ],
  exports: [
    FooterComponent,
    PrivacyPolicyComponent,
    TermsAndConditionsComponent,
  ],
  providers: [],
})
export class FooterModule {}
