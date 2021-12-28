import { AngularTokenService } from 'angular-token';
import { NgModule } from '@angular/core';
import { MethodExplorerComponent } from './method-explorer/method-explorer/method-explorer.component';
import { UserComponent } from '@core/user/user.component';
import { ResetPasswordComponent } from '@core/reset-password/reset-password.component';
import { UpdatePasswordComponent } from '@core/update-password/update-password.component';
import { ChangePasswordComponent } from '@core/change-password/change-password.component';
import { EditUserComponent } from '@core/edit-user/edit-user.component';
import { AchievementsComponent } from '@core/achievements/achievements.component';
import { AchievementGrantsComponent } from '@core/achievement-grants/achievement-grants.component';
import { AchievementComponent } from '@core/achievement/achievement.component';
import { MessageComponent } from '@core/message/message.component';
import { MessagesComponent } from '@core/messages/messages.component';
import { NewColorSchemeComponent } from './training/new-color-scheme/new-color-scheme.component';
import { NewLetterSchemeComponent } from './training/new-letter-scheme/new-letter-scheme.component';
import { SignupComponent } from '@core/signup/signup.component';
import { LoginComponent } from '@core/login/login.component';
import { LoggedOutComponent } from '@core/logged-out/logged-out.component';
import { AccountDeletedComponent } from '@core/account-deleted/account-deleted.component';
import { ConfirmEmailComponent } from '@core/confirm-email/confirm-email.component';
import { ModesComponent } from './training/modes/modes.component';
import { NewModeComponent } from './training/new-mode/new-mode.component';
import { TrainerComponent } from './training/trainer/trainer.component';
import { AboutComponent } from '@core/about/about.component';
import { CookiePolicyComponent } from '@core/cookie-policy/cookie-policy.component';
import { PrivacyPolicyComponent } from '@core/privacy-policy/privacy-policy.component';
import { ContactComponent } from '@core/contact/contact.component';
import { DisclaimerComponent } from '@core/disclaimer/disclaimer.component';
import { TermsAndConditionsComponent } from '@core/terms-and-conditions/terms-and-conditions.component';
import { RouterModule, Routes, ExtraOptions } from '@angular/router';
import { environment } from '@environment';

const routes: Routes = [
  { path: 'method_explorer', component: MethodExplorerComponent },
  { path: 'confirm_email', component: ConfirmEmailComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'reset_password', component: ResetPasswordComponent },
  { path: 'update_password', component: UpdatePasswordComponent },
  { path: 'change_password', component: ChangePasswordComponent, canActivate: [AngularTokenService] },
  { path: 'login', component: LoginComponent },
  { path: 'logged_out', component: LoggedOutComponent },
  { path: 'account_deleted', component: AccountDeletedComponent },
  { path: 'modes', component: ModesComponent, canActivate: [AngularTokenService] },
  { path: 'achievements', component: AchievementsComponent },
  { path: 'achievements/:achievementKey', component: AchievementComponent },
  { path: 'user', component: UserComponent, canActivate: [AngularTokenService] },
  { path: 'edit_user', component: EditUserComponent, canActivate: [AngularTokenService] },
  { path: 'achievement_grants', component: AchievementGrantsComponent, canActivate: [AngularTokenService] },
  { path: 'messages', component: MessagesComponent, canActivate: [AngularTokenService] },
  { path: 'messages/:messageId', component: MessageComponent, canActivate: [AngularTokenService] },
  { path: 'color_schemes/new', component: NewColorSchemeComponent, canActivate: [AngularTokenService] },
  { path: 'letter_schemes/new', component: NewLetterSchemeComponent, canActivate: [AngularTokenService] },
  { path: 'training/new', component: NewModeComponent, canActivate: [AngularTokenService] },
  { path: 'training/:modeId', component: TrainerComponent, canActivate: [AngularTokenService] },
  { path: 'about', component: AboutComponent },
  { path: 'privacy_policy', component: PrivacyPolicyComponent },
  { path: 'contact', component: ContactComponent },
  { path: 'cookie_policy', component: CookiePolicyComponent },
  { path: 'terms_and_conditions', component: TermsAndConditionsComponent },
  { path: 'disclaimer', component: DisclaimerComponent },
];

const routerOptions: ExtraOptions = {
  useHash: false,
  anchorScrolling: 'enabled',
  enableTracing: !environment.production,
};

@NgModule({
  imports: [RouterModule.forRoot(routes, routerOptions)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
