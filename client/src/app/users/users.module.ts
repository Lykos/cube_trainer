import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RailsModule } from '../rails/rails.module';
import { UsersService } from './users.service';
import { UserFormCreator } from './user-form-creator.service';
import { UserComponent } from './user/user.component';
import { MessagesComponent } from './messages/messages.component';
import { DeleteAccountButtonComponent } from './delete-account-button/delete-account-button.component';
import { DeleteAccountConfirmationDialogComponent } from './delete-account-confirmation-dialog/delete-account-confirmation-dialog.component';
import { MessageComponent } from './message/message.component';
import { AchievementsComponent } from './achievements/achievements.component';
import { AchievementComponent } from './achievement/achievement.component';
import { AchievementGrantsComponent } from './achievement-grants/achievement-grants.component';
import { MessagesService } from './messages.service';
import { AchievementsService } from './achievements.service';
import { UniqueUsernameOrEmailValidator } from './unique-username-or-email.validator';
import { AchievementGrantsService } from './achievement-grants.service';
import { ColorSchemesService } from './color-schemes.service';
import { LetterSchemesService } from './letter-schemes.service';
import { PartTypesService } from './part-types.service';
import { NgModule } from '@angular/core';
import { SignupComponent } from './signup/signup.component';
import { LoginComponent } from './login/login.component';
import { LoggedOutComponent } from './logged-out/logged-out.component';
import { ConfirmEmailComponent } from './confirm-email/confirm-email.component';
import { AccountDeletedComponent } from './account-deleted/account-deleted.component';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { UtilsModule } from '../utils/utils.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatSelectModule } from '@angular/material/select';
import { NewColorSchemeComponent } from './new-color-scheme/new-color-scheme.component'
import { NewLetterSchemeComponent } from './new-letter-scheme/new-letter-scheme.component'
import { MatDialogModule } from '@angular/material/dialog';
import { RouterModule } from '@angular/router';
import { EditUserComponent } from './edit-user/edit-user.component';
import { ResetPasswordComponent } from './reset-password/reset-password.component';
import { UpdatePasswordComponent } from './update-password/update-password.component';

@NgModule({
  declarations: [
    SignupComponent,
    LoginComponent,
    LoggedOutComponent,
    AccountDeletedComponent,
    AchievementsComponent,
    AchievementComponent,
    MessagesComponent,
    MessageComponent,
    AchievementGrantsComponent,
    UserComponent,
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    DeleteAccountButtonComponent,
    DeleteAccountConfirmationDialogComponent,
    ConfirmEmailComponent,
    EditUserComponent,
    ResetPasswordComponent,
    UpdatePasswordComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    RailsModule,
    MatButtonModule,
    MatCardModule,
    MatSelectModule,
    MatCheckboxModule,
    MatInputModule,
    MatTableModule,
    MatSnackBarModule,
    MatFormFieldModule,
    MatDialogModule,
    RouterModule,
    ReactiveFormsModule,
    FormsModule,
    MatTooltipModule,
    UtilsModule,
  ],
  providers: [
    UsersService,
    MessagesService,
    AchievementsService,
    UserFormCreator,
    AchievementGrantsService,
    ColorSchemesService,
    LetterSchemesService,
    PartTypesService,
    UniqueUsernameOrEmailValidator,
  ],
  exports: [
    AchievementComponent,
    EditUserComponent,
    SignupComponent,
    LoginComponent,
    LoggedOutComponent,
    AccountDeletedComponent,
    AchievementsComponent,
    AchievementGrantsComponent,
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    UserComponent,
    MessagesComponent,
    MessageComponent,
    ConfirmEmailComponent,
    ResetPasswordComponent,
    UpdatePasswordComponent,
  ],
})
export class UsersModule {}
