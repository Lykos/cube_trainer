import { BrowserModule } from '@angular/platform-browser';
import { RailsModule } from '../rails/rails.module';
import { UserService } from './user.service';
import { AuthenticationService } from './authentication.service';
import { NgModule } from '@angular/core';
import { SignupComponent } from './signup.component';
import { LoginComponent } from './login.component';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    SignupComponent,
    LoginComponent,
  ],
  imports: [
    BrowserModule,
    RailsModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatInputModule,
    MatFormFieldModule,
    FormsModule,
  ],
  providers: [
    AuthenticationService,
    UserService,
  ],
  exports: [
    SignupComponent,
    LoginComponent,
  ],
})
export class UserModule {}
