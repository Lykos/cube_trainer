import { MatSnackBar } from '@angular/material/snack-bar';
import { Component, OnInit } from '@angular/core';
import { FormGroup, AbstractControl } from '@angular/forms';
import { UserFormCreator } from '../user-form-creator.service';
import { UsersService } from '../users.service';
import { PasswordChange } from '../password-change.model';

@Component({
  selector: 'cube-trainer-change-password',
  templateUrl: './change-password.component.html',
  styleUrls: ['./change-password.component.css']
})
export class ChangePasswordComponent implements OnInit {
  form!: FormGroup;

  constructor(private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar,
              private readonly usersService: UsersService) {}

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
    
  ngOnInit() {
    this.form = this.userFormCreator.createChangePasswordForm();
  }
}
