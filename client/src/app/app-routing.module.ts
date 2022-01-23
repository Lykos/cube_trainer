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
import { EditColorSchemeComponent } from './training/edit-color-scheme/edit-color-scheme.component';
import { NewLetterSchemeComponent } from './training/new-letter-scheme/new-letter-scheme.component';
import { SignupComponent } from '@core/signup/signup.component';
import { LoginComponent } from '@core/login/login.component';
import { LoggedOutComponent } from '@core/logged-out/logged-out.component';
import { AccountDeletedComponent } from '@core/account-deleted/account-deleted.component';
import { ConfirmEmailComponent } from '@core/confirm-email/confirm-email.component';
import { TrainingSessionsComponent } from './training/training-sessions/training-sessions.component';
import { NewTrainingSessionComponent } from './training/new-training-session/new-training-session.component';
import { TrainerComponent } from './training/trainer/trainer.component';
import { WelcomeComponent } from '@core/welcome/welcome.component';
import { AboutComponent } from '@core/about/about.component';
import { CookiePolicyComponent } from '@core/cookie-policy/cookie-policy.component';
import { PrivacyPolicyComponent } from '@core/privacy-policy/privacy-policy.component';
import { ContactComponent } from '@core/contact/contact.component';
import { DisclaimerComponent } from '@core/disclaimer/disclaimer.component';
import { TermsAndConditionsComponent } from '@core/terms-and-conditions/terms-and-conditions.component';
import { NotFoundComponent } from '@core/not-found/not-found.component';
import { RouterModule, Routes, ExtraOptions } from '@angular/router';
import { environment } from '@environment';

const routes: Routes = [
  { path: 'welcome', component: WelcomeComponent },
  { path: 'method-explorer', component: MethodExplorerComponent },
  { path: 'confirm-email', component: ConfirmEmailComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'reset-password', component: ResetPasswordComponent },
  { path: 'update-password', component: UpdatePasswordComponent },
  { path: 'change-password', component: ChangePasswordComponent, canActivate: [AngularTokenService] },
  { path: 'login', component: LoginComponent },
  { path: 'logged-out', component: LoggedOutComponent },
  { path: 'account-deleted', component: AccountDeletedComponent },
  { path: 'training-sessions', component: TrainingSessionsComponent, canActivate: [AngularTokenService] },
  { path: 'achievements', component: AchievementsComponent },
  { path: 'achievements/:achievementId', component: AchievementComponent },
  { path: 'user', component: UserComponent, canActivate: [AngularTokenService] },
  { path: 'edit-user', component: EditUserComponent, canActivate: [AngularTokenService] },
  { path: 'achievement-grants', component: AchievementGrantsComponent, canActivate: [AngularTokenService] },
  { path: 'messages', component: MessagesComponent, canActivate: [AngularTokenService] },
  { path: 'messages/:messageId', component: MessageComponent, canActivate: [AngularTokenService] },
  { path: 'color-scheme', component: EditColorSchemeComponent, canActivate: [AngularTokenService] },
  { path: 'letter-schemes/new', component: NewLetterSchemeComponent, canActivate: [AngularTokenService] },
  { path: 'training-sessions/new', component: NewTrainingSessionComponent, canActivate: [AngularTokenService] },
  { path: 'training-sessions/:trainingSessionId', component: TrainerComponent, canActivate: [AngularTokenService] },
  { path: 'about', component: AboutComponent },
  { path: 'privacy-policy', component: PrivacyPolicyComponent },
  { path: 'contact', component: ContactComponent },
  { path: 'cookie-policy', component: CookiePolicyComponent },
  { path: 'terms-and-conditions', component: TermsAndConditionsComponent },
  { path: 'disclaimer', component: DisclaimerComponent },
  { path: '', pathMatch: 'full', redirectTo: '/welcome' },
  { path: '**', component: NotFoundComponent },
];

const routerOptions: ExtraOptions = {
  useHash: false,
  anchorScrolling: 'enabled',
  enableTracing: !environment.production,
};

@NgModule({
  imports: [
    RouterModule.forRoot(routes, routerOptions),
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
