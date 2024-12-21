import { MatSnackBar } from '@angular/material/snack-bar';
import { Component, OnInit } from '@angular/core';
import { FormGroup, AbstractControl } from '@angular/forms';
import { UserFormCreator } from '../user-form-creator.service';
import { UsersService } from '../users.service';
import { PasswordUpdate } from '../password-update.model';

// Component for updating the user password.
// The user needs a link from an email to change the password.
// For the normal password change flow that requires no email but the old password,
// see ChangePasswordComponent.
@Component({
  selector: 'cube-trainer-update-password',
  templateUrl: './update-password.component.html',
  styleUrls: ['./update-password.component.css']
})
export class UpdatePasswordComponent implements OnInit {
  form!: FormGroup;

  constructor(private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar,
              private readonly usersService: UsersService) {}

  get passwordControl() { return this.form.get('password')!; }

  get passwordConfirmationControl() { return this.form.get('passwordConfirmation')!; }

  get passwordUpdate(): PasswordUpdate {
    return {
      password: this.passwordControl.value,
      passwordConfirmation: this.passwordConfirmationControl.value
    };
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  onSubmit() {
    this.usersService.updatePassword(this.passwordUpdate).subscribe(r => {
      this.snackBar.open('Password updated!', 'Close');
    });
  }
    
  ngOnInit() {
    this.form = this.userFormCreator.createUpdatePasswordForm();
  }
}
