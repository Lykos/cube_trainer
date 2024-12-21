import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { FormGroup, AbstractControl } from '@angular/forms';
import { UserFormCreator } from '../user-form-creator.service';
import { NewUser } from '../new-user.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'cube-trainer-signup',
  templateUrl: './signup.component.html',
})
export class SignupComponent implements OnInit {
  signupForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
              private readonly dialog: MatDialog,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly userFormCreator: UserFormCreator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.signupForm = this.userFormCreator.createSignupForm();
  }

  onSubmit() {
    const newUser = this.newUser;
    this.usersService.create(newUser).subscribe(
      () => {
        this.snackBar.open('Signup successful!', 'Close');
        this.router.navigate(['/login']);
      },
      error => {
        const context = {
          action: 'registering',
          subject: newUser.name,
        };
        this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
      }
    );
  }
    
  get name() { return this.signupForm.get('name')!; }

  get email() { return this.signupForm.get('email')!; }

  get password() { return this.signupForm.get('password')!; }

  get passwordConfirmation() { return this.signupForm.get('passwordConfirmation')!; }

  get termsAndConditionsAccepted() { return this.signupForm.get('termsAndConditionsAccepted')!; }

  get newUser(): NewUser {
    return {
      name: this.name.value,
      email: this.email.value,
      password: this.password.value,
      passwordConfirmation: this.passwordConfirmation.value,
    };
  }

  get passwordMismatch() {
    return this.signupForm.errors && this.signupForm.errors['passwordMismatch'] && (this.passwordConfirmation.touched || this.passwordConfirmation.dirty);
  }
}
