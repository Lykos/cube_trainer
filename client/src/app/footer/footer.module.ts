import { NgModule } from '@angular/core';
import { FooterComponent } from './footer/footer.component';
import { AboutComponent } from './about/about.component';
import { MaintainerNameComponent } from './maintainer-name/maintainer-name.component';
import { ContactComponent } from './contact/contact.component';
import { ContactContentComponent } from './contact-content/contact-content.component';
import { PrivacyPolicyComponent } from './privacy-policy/privacy-policy.component';
import { CookiePolicyComponent } from './cookie-policy/cookie-policy.component';
import { TermsAndConditionsComponent } from './terms-and-conditions/terms-and-conditions.component';
import { DisclaimerComponent } from './disclaimer/disclaimer.component';
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
