import { NgModule } from '@angular/core';
import { MethodExplorerComponent } from './method-explorer/method-explorer/method-explorer.component';
import { UserComponent } from './users/user/user.component';
import { ResetPasswordComponent } from './users/reset-password/reset-password.component';
import { UpdatePasswordComponent } from './users/update-password/update-password.component';
import { ChangePasswordComponent } from './users/change-password/change-password.component';
import { EditUserComponent } from './users/edit-user/edit-user.component';
import { AchievementsComponent } from './users/achievements/achievements.component';
import { AchievementGrantsComponent } from './users/achievement-grants/achievement-grants.component';
import { AchievementComponent } from './users/achievement/achievement.component';
import { MessageComponent } from './users/message/message.component';
import { MessagesComponent } from './users/messages/messages.component';
import { NewColorSchemeComponent } from './users/new-color-scheme/new-color-scheme.component';
import { NewLetterSchemeComponent } from './users/new-letter-scheme/new-letter-scheme.component';
import { SignupComponent } from './users/signup/signup.component';
import { LoginComponent } from './users/login/login.component';
import { LoggedOutComponent } from './users/logged-out/logged-out.component';
import { AccountDeletedComponent } from './users/account-deleted/account-deleted.component';
import { ConfirmEmailComponent } from './users/confirm-email/confirm-email.component';
import { ModesComponent } from './modes/modes/modes.component';
import { NewModeComponent } from './modes/new-mode/new-mode.component';
import { TrainerComponent } from './trainer/trainer/trainer.component';
import { AboutComponent } from './footer/about/about.component';
import { CookiePolicyComponent } from './footer/cookie-policy/cookie-policy.component';
import { PrivacyPolicyComponent } from './footer/privacy-policy/privacy-policy.component';
import { ContactComponent } from './footer/contact/contact.component';
import { DisclaimerComponent } from './footer/disclaimer/disclaimer.component';
import { TermsAndConditionsComponent } from './footer/terms-and-conditions/terms-and-conditions.component';
import { TwistyPlayerComponent } from './trainer/twisty-player/twisty-player.component';
import { RouterModule, Routes, ExtraOptions } from '@angular/router';
import { environment } from './../environments/environment';

const routes: Routes = [
  { path: 'method_explorer', component: MethodExplorerComponent },
  { path: 'confirm_email', component: ConfirmEmailComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'reset_password', component: ResetPasswordComponent },
  { path: 'update_password', component: UpdatePasswordComponent },
  { path: 'change_password', component: ChangePasswordComponent },
  { path: 'login', component: LoginComponent },
  { path: 'logged_out', component: LoggedOutComponent },
  { path: 'account_deleted', component: AccountDeletedComponent },
  { path: 'modes', component: ModesComponent },
  { path: 'achievements', component: AchievementsComponent },
  { path: 'achievements/:achievementKey', component: AchievementComponent },
  { path: 'user', component: UserComponent },
  { path: 'edit_user', component: EditUserComponent },
  { path: 'achievement_grants', component: AchievementGrantsComponent },
  { path: 'messages', component: MessagesComponent },
  { path: 'messages/:messageId', component: MessageComponent },
  { path: 'color_schemes/new', component: NewColorSchemeComponent },
  { path: 'letter_schemes/new', component: NewLetterSchemeComponent },
  { path: 'modes/new', component: NewModeComponent },
  { path: 'trainer/:modeId', component: TrainerComponent },
  { path: 'about', component: AboutComponent },
  { path: 'privacy_policy', component: PrivacyPolicyComponent },
  { path: 'contact', component: ContactComponent },
  { path: 'cookie_policy', component: CookiePolicyComponent },
  { path: 'terms_and_conditions', component: TermsAndConditionsComponent },
  { path: 'disclaimer', component: DisclaimerComponent },
  { path: 'twisty_player', component: TwistyPlayerComponent },
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
