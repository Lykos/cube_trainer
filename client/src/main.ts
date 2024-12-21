import { enableProdMode, importProvidersFrom } from '@angular/core';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';


import { environment } from './environments/environment';
import { APP_BASE_HREF } from '@angular/common';
import { AngularTokenModule } from '@angular-token/angular-token.module';
import { BrowserModule, bootstrapApplication } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations';
import { MethodExplorerModule } from './app/method-explorer/method-explorer.module';
import { AppRoutingModule } from './app/app-routing.module';
import { withInterceptorsFromDi, provideHttpClient } from '@angular/common/http';
import { CoreModule } from '@core/core.module';
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
import { AppComponent } from './app/app.component';

if (environment.production) {
  enableProdMode();
}

bootstrapApplication(AppComponent, {
    providers: [
        importProvidersFrom(BrowserModule, MethodExplorerModule, AppRoutingModule, CoreModule, 
        // TODO: Figure out whether we can move this to the core module.
        // TODO: Don't use the host, use Location and PathLocationStrategy.
        AngularTokenModule.forRoot({
            loginField: 'email',
            signInRedirect: 'login',
            signInStoredUrlStorageKey: METADATA.signInStoredUrlStorageKey,
            apiBase: environment.apiPrefix,
            registerAccountCallback: `${environment.redirectProtocol}://${environment.host}/confirm-email`,
            resetPasswordCallback: `${environment.redirectProtocol}://${environment.host}/update-password`,
        }), StoreModule.forRoot({
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
        }), StoreRouterConnectingModule.forRoot(), EffectsModule.forRoot([
            UserEffects,
            TrainingSessionsEffects,
            TrainerEffects,
            ColorSchemeEffects,
            LetterSchemeEffects,
        ]), StoreDevtoolsModule.instrument({
            maxAge: 25, // Retains last 25 states
            logOnly: environment.production, // Restrict extension to log-only mode
            autoPause: true, // Pauses recording actions and state changes when the extension window is not open
        })),
        { provide: APP_BASE_HREF, useValue: '/' },
        AngularTokenModule,
        provideAnimations(),
        provideHttpClient(withInterceptorsFromDi())
    ]
})
  .catch(err => console.error(err));
