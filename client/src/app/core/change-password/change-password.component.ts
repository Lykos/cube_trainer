import { MatSnackBar } from '@angular/material/snack-bar';
import { Component } from '@angular/core';
import { FormGroup, AbstractControl, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { UserFormCreator } from '../user-form-creator.service';
import { UsersService } from '../users.service';
import { PasswordChange } from '../password-change.model';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';

// Component for changing the user password.
// The user needs their old password to change the password.
// For updating the password after the password forgotten flow where the old password is not available,
// see UpdatePasswordComponent.
@Component({
  selector: 'cube-trainer-change-password',
  templateUrl: './change-password.component.html',
  styleUrls: ['./change-password.component.css'],
  imports: [FormsModule, ReactiveFormsModule, MatFormFieldModule, MatCardModule, MatButtonModule, MatInputModule],
})
export class ChangePasswordComponent {
  form: FormGroup;

  constructor(private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar,
              private readonly usersService: UsersService) {
    this.form = this.userFormCreator.createChangePasswordForm();
  }

  get currentPasswordControl() { return this.form.get('currentPassword')!; }

  get passwordControl() { return this.form.get('password')!; }

  get passwordConfirmationControl() { return this.form.get('passwordConfirmation')!; }

  get passwordChange(): PasswordChange {
    return {
      passwordCurrent: this.currentPasswordControl.value,
      password: this.passwordControl.value,
      passwordConfirmation: this.passwordConfirmationControl.value
    };
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  onSubmit() {
    this.usersService.changePassword(this.passwordChange).subscribe(r => {
      this.snackBar.open('Password changed!', 'Close');
    },
    err => {
      // TODO: Get 422 from a constant.
      if (err.status == 422) {
	this.currentPasswordControl.setErrors({'wrongcurrentpassword': true});
      }
    });
  }
}
