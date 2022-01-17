import { AboutComponent } from './about/about.component';
import { AccountDeletedComponent } from './account-deleted/account-deleted.component';
import { AchievementComponent } from './achievement/achievement.component';
import { AchievementGrantsComponent } from './achievement-grants/achievement-grants.component';
import { AchievementsComponent } from './achievements/achievements.component';
import { ChangePasswordComponent } from './change-password/change-password.component';
import { ConfirmEmailComponent } from './confirm-email/confirm-email.component';
import { ContactComponent } from './contact/contact.component';
import { ContactContentComponent } from './contact-content/contact-content.component';
import { CookiePolicyComponent } from './cookie-policy/cookie-policy.component';
import { CookieService } from 'ngx-cookie-service';
import { DeleteAccountButtonComponent } from './delete-account-button/delete-account-button.component';
import { DeleteAccountConfirmationDialogComponent } from './delete-account-confirmation-dialog/delete-account-confirmation-dialog.component';
import { DisclaimerComponent } from './disclaimer/disclaimer.component';
import { EditUserComponent } from './edit-user/edit-user.component';
import { FileSaverModule } from 'ngx-filesaver';
import { FooterComponent } from './footer/footer.component';
import { GoogleAnalyticsReferenceComponent } from './google-analytics-reference/google-analytics-reference.component';
import { HttpClientModule } from '@angular/common/http';
import { LoggedOutComponent } from './logged-out/logged-out.component';
import { LoginComponent } from './login/login.component';
import { MaintainerNameComponent } from './maintainer-name/maintainer-name.component';
import { MatBadgeModule } from '@angular/material/badge';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTabsModule } from '@angular/material/tabs';
import { MessageComponent } from './message/message.component';
import { MessagesComponent } from './messages/messages.component';
import { NgModule } from '@angular/core';
import { PrivacyPolicyComponent } from './privacy-policy/privacy-policy.component';
import { ResetPasswordComponent } from './reset-password/reset-password.component';
import { SharedModule } from '@shared/shared.module';
import { SignupComponent } from './signup/signup.component';
import { TermsAndConditionsComponent } from './terms-and-conditions/terms-and-conditions.component';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { UpdatePasswordComponent } from './update-password/update-password.component';
import { UserComponent } from './user/user.component';
import { NotFoundComponent } from './not-found/not-found.component';
import { NavigationBarComponent } from './navigation-bar/navigation-bar.component';

@NgModule({
  declarations: [
    ToolbarComponent,
    SignupComponent,
    LoginComponent,
    LoggedOutComponent,
    AccountDeletedComponent,
    AchievementsComponent,
    AchievementComponent,
    MessagesComponent,
    MessageComponent,
    AchievementGrantsComponent,
    UserComponent,
    DeleteAccountButtonComponent,
    DeleteAccountConfirmationDialogComponent,
    ConfirmEmailComponent,
    EditUserComponent,
    ResetPasswordComponent,
    UpdatePasswordComponent,
    ChangePasswordComponent,
    FooterComponent,
    AboutComponent,
    ContactComponent,
    ContactContentComponent,
    PrivacyPolicyComponent,
    CookiePolicyComponent,
    TermsAndConditionsComponent,
    DisclaimerComponent,
    MaintainerNameComponent,
    GoogleAnalyticsReferenceComponent,
    NotFoundComponent,
    NavigationBarComponent,
  ],
  imports: [
    FileSaverModule,
    MatBadgeModule,
    MatTabsModule,
    MatToolbarModule,
    SharedModule,
    HttpClientModule,
  ],
  providers: [
    CookieService,
  ],
  exports: [
    AchievementComponent,
    EditUserComponent,
    SignupComponent,
    LoginComponent,
    LoggedOutComponent,
    AccountDeletedComponent,
    AchievementsComponent,
    AchievementGrantsComponent,
    UserComponent,
    MessagesComponent,
    MessageComponent,
    ConfirmEmailComponent,
    ResetPasswordComponent,
    UpdatePasswordComponent,
    ChangePasswordComponent,
    ToolbarComponent,
    FooterComponent,
  ],
})
export class CoreModule {}
