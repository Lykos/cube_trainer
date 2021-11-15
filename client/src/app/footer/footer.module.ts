import { NgModule } from '@angular/core';
import { FooterComponent } from './footer.component';
import { AboutComponent } from './about.component';
import { MaintainerNameComponent } from './maintainer-name.component';
import { ContactComponent } from './contact.component';
import { ContactContentComponent } from './contact-content.component';
import { PrivacyPolicyComponent } from './privacy-policy.component';
import { CookiePolicyComponent } from './cookie-policy.component';
import { TermsAndConditionsComponent } from './terms-and-conditions.component';
import { DisclaimerComponent } from './disclaimer.component';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [
    FooterComponent,
    AboutComponent,
    ContactComponent,
    ContactContentComponent,
    PrivacyPolicyComponent,
    CookiePolicyComponent,
    TermsAndConditionsComponent,
    DisclaimerComponent,
    MaintainerNameComponent,
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
    AboutComponent,
    ContactComponent,
    ContactContentComponent,
    PrivacyPolicyComponent,
    CookiePolicyComponent,
    TermsAndConditionsComponent,
    DisclaimerComponent,
    MaintainerNameComponent,
  ],
  providers: [],
})
export class FooterModule {}
