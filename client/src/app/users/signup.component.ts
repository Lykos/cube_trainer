import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';
import { FormGroup, AbstractControl } from '@angular/forms';
import { UserFormCreator } from './user-form-creator.service';
import { NewUser } from './new-user';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';

@Component({
  selector: 'cube-trainer-signup',
  templateUrl: './signup.component.html'
})
export class SignupComponent implements OnInit {
  signupForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly userFormCreator: UserFormCreator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.signupForm = this.userFormCreator.createUserForm();
  }

  onSubmit() {
    this.usersService.create(this.newUser).subscribe(r => {
      this.snackBar.open('Signup successful!', 'Close');
      this.router.navigate(['/login']);
    });
  }
    
  get name() { return this.signupForm.get('name')!; }

  get email() { return this.signupForm.get('email')!; }

  get password() { return this.signupForm.get('password')!; }

  get passwordConfirmation() { return this.signupForm.get('passwordConfirmation')!; }

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
