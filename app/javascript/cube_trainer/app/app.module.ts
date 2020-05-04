import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AppComponent } from './app.component';
import { UsersModule } from './users/users.module';
import { UserComponent } from './users/user.component';
import { AchievementsComponent } from './users/achievements.component';
import { AchievementGrantsComponent } from './users/achievement-grants.component';
import { AchievementComponent } from './users/achievement.component';
import { MessageComponent } from './users/message.component';
import { MessagesComponent } from './users/messages.component';
import { ColorSchemeComponent } from './users/color-scheme.component';
import { SignupComponent } from './users/signup.component';
import { LoginComponent } from './users/login.component';
import { ModesComponent } from './modes/modes.component';
import { NewModeComponent } from './modes/new-mode.component';
import { ModesModule } from './modes/modes.module';
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
  { path: 'achievements/:achievementKey', component: AchievementComponent },
  { path: 'users/:userId', component: UserComponent },
  { path: 'users/:userId/achievement_grants', component: AchievementGrantsComponent },
  { path: 'users/:userId/messages', component: MessagesComponent },
  { path: 'users/:userId/messages/:messageId', component: MessageComponent },
  { path: 'users/:userId/color_scheme', component: ColorSchemeComponent },
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
    UsersModule,
    ModesModule,
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
