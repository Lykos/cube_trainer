import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AppComponent } from './app.component';
import { UserModule } from './user/user.module';
import { UserComponent } from './user/user.component';
import { AchievementsComponent } from './user/achievements.component';
import { SignupComponent } from './user/signup.component';
import { LoginComponent } from './user/login.component';
import { ModesComponent } from './mode/modes.component';
import { NewModeComponent } from './mode/new-mode.component';
import { ModeModule } from './mode/mode.module';
import { TrainerModule } from './trainer/trainer.module';
import { TrainerComponent } from './trainer/trainer.component';
import { ToolbarModule } from './toolbar/toolbar.module';
import { RouterModule, Routes } from '@angular/router';
import { APP_BASE_HREF } from '@angular/common';

const appRoutes: Routes = [
  { path: 'signup', component: SignupComponent },
  { path: 'login', component: LoginComponent },
  { path: 'modes', component: ModesComponent },
  { path: 'achievements', component: AchievementsComponent },
  { path: 'users/:userId', component: UserComponent },
  { path: 'modes/new', component: NewModeComponent },
  { path: 'trainer/:modeId', component: TrainerComponent },
];

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    ToolbarModule,
    TrainerModule,
    UserModule,
    ModeModule,
    RouterModule.forRoot(
      appRoutes,
      { enableTracing: true } // <-- debugging purposes only
    )
  ],
  bootstrap: [
    AppComponent,
  ],
  providers: [
    {provide: APP_BASE_HREF, useValue: '/'},
  ],
})
export class AppModule { }
