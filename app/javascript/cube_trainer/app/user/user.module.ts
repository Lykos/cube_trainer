import { BrowserModule } from '@angular/platform-browser';
import { RailsModule } from '../rails/rails.module';
import { UserService } from './user.service';
import { UserComponent } from './user.component';
import { MessagesComponent } from './messages.component';
import { MessageComponent } from './message.component';
import { AchievementsComponent } from './achievements.component';
import { AchievementComponent } from './achievement.component';
import { AchievementGrantsComponent } from './achievement-grants.component';
import { AuthenticationService } from './authentication.service';
import { MessagesService } from './messages.service';
import { AchievementsService } from './achievements.service';
import { AchievementGrantsService } from './achievement-grants.service';
import { NgModule } from '@angular/core';
import { SignupComponent } from './signup.component';
import { LoginComponent } from './login.component';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { UtilsModule } from '../utils/utils.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    SignupComponent,
    LoginComponent,
    AchievementsComponent,
    AchievementComponent,
    MessagesComponent,
    MessageComponent,
    AchievementGrantsComponent,
    UserComponent,
  ],
  imports: [
    BrowserModule,
    RailsModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatInputModule,
    MatTableModule,
    MatFormFieldModule,
    ReactiveFormsModule,
    FormsModule,
    UtilsModule,
  ],
  providers: [
    AuthenticationService,
    UserService,
    MessagesService,
    AchievementsService,
    AchievementGrantsService,
  ],
  exports: [
    AchievementComponent,
    SignupComponent,
    LoginComponent,
    AchievementsComponent,
    AchievementGrantsComponent,
    UserComponent,
    MessagesComponent,
    MessageComponent,
  ],
})
export class UserModule {}
