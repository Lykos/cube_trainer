import { AppRoutingModule } from './app-routing.module';
import { HttpClientModule } from '@angular/common/http';
import { AngularTokenModule } from 'angular-token';
import { environment } from '../environments/environment';
import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { UsersModule } from './users/users.module';
import { ModesModule } from './modes/modes.module';
import { FooterModule } from './footer/footer.module';
import { TrainerModule } from './trainer/trainer.module';
import { ToolbarModule } from './toolbar/toolbar.module';
import { APP_BASE_HREF } from '@angular/common';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    ToolbarModule,
    TrainerModule,
    UsersModule,
    ModesModule,
    FooterModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    HttpClientModule,
    AngularTokenModule.forRoot({
      loginField: 'email',
      apiBase: environment.apiPrefix,
    }),
  ],
  providers: [
    {provide: APP_BASE_HREF, useValue: '/'},
    AngularTokenModule,    
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
