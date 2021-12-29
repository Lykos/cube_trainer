import { AppRoutingModule } from './app-routing.module';
import { HttpClientModule } from '@angular/common/http';
import { AngularTokenModule } from 'angular-token';
import { METADATA } from '@shared/metadata.const';
import { environment } from '../environments/environment';
import { AppComponent } from './app.component';
import { NgModule } from '@angular/core';
import { StoreModule } from '@ngrx/store';
import { CoreModule } from '@core/core.module';
import { SharedModule } from '@shared/shared.module';
import { TrainingModule } from '@training/training.module';
import { MethodExplorerModule } from './method-explorer/method-explorer.module';
import { APP_BASE_HREF } from '@angular/common';
// TODO: Move this to a better place
import { userReducer } from '@store/user.reducer';
import { modesReducer } from '@store/modes.reducer';
import { resultsReducer } from '@store/results.reducer';
import { EffectsModule } from '@ngrx/effects';
import { UserEffects } from '@effects/user.effects';
import { ModesEffects } from '@effects/modes.effects';
import { ResultsEffects } from '@effects/results.effects';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    MethodExplorerModule,
    TrainingModule,
    AppRoutingModule,
    HttpClientModule,
    CoreModule,
    SharedModule,
    // TODO: Figure out whether we can move this to the core module.
    // TODO: Don't use the host, use Location and PathLocationStrategy.
    AngularTokenModule.forRoot({
      loginField: 'email',
      signInRedirect: 'login',
      signInStoredUrlStorageKey: METADATA.signInStoredUrlStorageKey,
      apiBase: environment.apiPrefix,
      registerAccountCallback: `${environment.redirectProtocol}://${environment.host}/confirm_email`,
      resetPasswordCallback: `${environment.redirectProtocol}://${environment.host}/update_password`,
    }),
    StoreModule.forRoot(
      { user: userReducer, modes: modesReducer, results: resultsReducer },
      {
        runtimeChecks: {
          strictStateImmutability: true,
          strictActionImmutability: true,
          strictStateSerializability: true,
          strictActionSerializability: true,
          strictActionWithinNgZone: true,
          strictActionTypeUniqueness: true,
        },
      },
    ),
    EffectsModule.forRoot([UserEffects, ModesEffects, ResultsEffects]),
    StoreDevtoolsModule.instrument({
      maxAge: 25, // Retains last 25 states
      logOnly: environment.production, // Restrict extension to log-only mode
      autoPause: true, // Pauses recording actions and state changes when the extension window is not open
    }),
  ],
  providers: [
    { provide: APP_BASE_HREF, useValue: '/' },
    AngularTokenModule,    
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
