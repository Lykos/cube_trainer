import { importProvidersFrom, ApplicationConfig } from '@angular/core';
import { environment } from '@environment';
import { APP_BASE_HREF } from '@angular/common';
import { AngularTokenModule } from '@angular-token/angular-token.module';
import { BrowserModule } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations';
import { MethodExplorerModule } from './method-explorer/method-explorer.module';
import { withInterceptorsFromDi, provideHttpClient } from '@angular/common/http';
import { METADATA } from '@shared/metadata.const';
import { StoreModule } from '@ngrx/store';
import { userReducer } from '@store/user.reducer';
import { trainingSessionsReducer } from '@store/training-sessions.reducer';
import { trainerReducer } from '@store/trainer.reducer';
import { routerReducer, StoreRouterConnectingModule } from '@ngrx/router-store';
import { colorSchemeReducer } from '@store/color-scheme.reducer';
import { letterSchemeReducer } from '@store/letter-scheme.reducer';
import { EffectsModule } from '@ngrx/effects';
import { UserEffects } from '@effects/user.effects';
import { TrainingSessionsEffects } from '@effects/training-sessions.effects';
import { TrainerEffects } from '@effects/trainer.effects';
import { ColorSchemeEffects } from '@effects/color-scheme.effects';
import { LetterSchemeEffects } from '@effects/letter-scheme.effects';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';
import { CookieService } from 'ngx-cookie-service';
import { FileSaverModule } from 'ngx-filesaver';
import { HttpClientModule } from '@angular/common/http';
import { AngularTokenService } from '@angular-token/angular-token.service';
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
import { EditLetterSchemeComponent } from './training/edit-letter-scheme/edit-letter-scheme.component';
import { SignupComponent } from '@core/signup/signup.component';
import { LoginComponent } from '@core/login/login.component';
import { LoggedOutComponent } from '@core/logged-out/logged-out.component';
import { AccountDeletedComponent } from '@core/account-deleted/account-deleted.component';
import { ConfirmEmailComponent } from '@core/confirm-email/confirm-email.component';
import { TrainingSessionsComponent } from './training/training-sessions/training-sessions.component';
import { NewTrainingSessionComponent } from './training/new-training-session/new-training-session.component';
import { TrainingSessionComponent } from './training/training-session/training-session.component';
import { AlgSetComponent } from './training/alg-set/alg-set.component';
import { WelcomeComponent } from '@core/welcome/welcome.component';
import { AboutComponent } from '@core/about/about.component';
import { CookiePolicyComponent } from '@core/cookie-policy/cookie-policy.component';
import { PrivacyPolicyComponent } from '@core/privacy-policy/privacy-policy.component';
import { ContactComponent } from '@core/contact/contact.component';
import { DisclaimerComponent } from '@core/disclaimer/disclaimer.component';
import { TermsAndConditionsComponent } from '@core/terms-and-conditions/terms-and-conditions.component';
import { NotFoundComponent } from '@core/not-found/not-found.component';
import { RouterModule, Routes, ExtraOptions } from '@angular/router';

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
  { path: 'letter-scheme', component: EditLetterSchemeComponent, canActivate: [AngularTokenService] },
  { path: 'training-sessions/new', component: NewTrainingSessionComponent, canActivate: [AngularTokenService] },
  { path: 'training-sessions/:trainingSessionId', component: TrainingSessionComponent, canActivate: [AngularTokenService] },
  { path: 'alg-sets/:trainingSessionId', component: AlgSetComponent, canActivate: [AngularTokenService] },
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

export const appConfig: ApplicationConfig = {
    providers: [
      CookieService,
      importProvidersFrom(
	BrowserModule, MethodExplorerModule, FileSaverModule, HttpClientModule,
	RouterModule.forRoot(routes, routerOptions),
        // TODO: Figure out whether we can move this to the core module.
        // TODO: Don't use the host, use Location and PathLocationStrategy.
        AngularTokenModule.forRoot({
          loginField: 'email',
          signInRedirect: 'login',
          signInStoredUrlStorageKey: METADATA.signInStoredUrlStorageKey,
          apiBase: environment.apiPrefix,
          registerAccountCallback: `${environment.redirectProtocol}://${environment.host}/confirm-email`,
          resetPasswordCallback: `${environment.redirectProtocol}://${environment.host}/update-password`,
        }),
	StoreModule.forRoot({
            user: userReducer,
            trainingSessions: trainingSessionsReducer,
            trainer: trainerReducer,
            router: routerReducer,
            colorScheme: colorSchemeReducer,
            letterScheme: letterSchemeReducer,
        }, {
            runtimeChecks: {
                strictStateImmutability: true,
                strictActionImmutability: true,
                strictStateSerializability: true,
                strictActionSerializability: true,
                strictActionWithinNgZone: true,
                strictActionTypeUniqueness: true,
            },
        }),
	StoreRouterConnectingModule.forRoot(),
	EffectsModule.forRoot([
            UserEffects,
            TrainingSessionsEffects,
            TrainerEffects,
            ColorSchemeEffects,
            LetterSchemeEffects,
        ]),
	StoreDevtoolsModule.instrument({
            maxAge: 25, // Retains last 25 states
            logOnly: environment.production, // Restrict extension to log-only mode
            autoPause: true, // Pauses recording actions and state changes when the extension window is not open
        })),
      { provide: APP_BASE_HREF, useValue: '/' },
      AngularTokenModule,
      provideAnimations(),
      provideHttpClient(withInterceptorsFromDi())
    ]
}
