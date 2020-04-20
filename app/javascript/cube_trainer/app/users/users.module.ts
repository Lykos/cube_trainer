import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RailsModule } from '../rails/rails.module';
import { UsersService } from './users.service';
import { UserComponent } from './user.component';
import { MessagesComponent } from './messages.component';
import { MessageComponent } from './message.component';
import { AchievementsComponent } from './achievements.component';
import { AchievementComponent } from './achievement.component';
import { AchievementGrantsComponent } from './achievement-grants.component';
import { AuthenticationService } from './authentication.service';
import { MessagesService } from './messages.service';
import { AchievementsService } from './achievements.service';
import { UniqueUsernameOrEmailValidator } from './unique-username-or-email.validator';
import { AchievementGrantsService } from './achievement-grants.service';
import { NgModule } from '@angular/core';
import { SignupComponent } from './signup.component';
import { LoginComponent } from './login.component';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { UtilsModule } from '../utils/utils.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import {MatTooltipModule} from '@angular/material/tooltip';


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
    BrowserAnimationsModule,
    RailsModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatInputModule,
    MatTableModule,
    MatSnackBarModule,
    MatFormFieldModule,
    ReactiveFormsModule,
    FormsModule,
    MatTooltipModule,
    UtilsModule,
  ],
  providers: [
    AuthenticationService,
    UsersService,
    MessagesService,
    AchievementsService,
    AchievementGrantsService,
    UniqueUsernameOrEmailValidator,
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
export class UsersModule {}
