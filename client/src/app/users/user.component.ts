import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';
import { User } from './user';
import { FormGroup, AbstractControl } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserUpdate } from './user-update.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
import { UserFormCreator } from './user-form-creator.service';

@Component({
  selector: 'cube-trainer-user',
  template: `
<div *ngIf="user">
  <h1>{{user.name}}</h1>
  <form [formGroup]="editUserForm" (ngSubmit)="onSubmit()">
    <mat-form-field appearance="fill">
      <mat-label>Username</mat-label>
      <input type="text" matInput formControlName="name">
      <mat-error *ngIf="relevantInvalid(name) && name.errors && name.errors['required']">
        You must provide a <strong>username</strong>.
      </mat-error>
      <mat-error *ngIf="relevantInvalid(name) && name.errors && name.errors['uniqueUsernameOrEmail']">
        This <strong>username</strong> is already taken.
      </mat-error>
    </mat-form-field>
    <br>
    <mat-form-field appearance="fill">
      <mat-label>Email</mat-label>
      <input type="email" matInput formControlName="email">
      <mat-error *ngIf="relevantInvalid(email) && email.errors && email.errors['required']">
        You must provide an <strong>email</strong>.
      </mat-error>
      <mat-error *ngIf="relevantInvalid(email) && email.errors && email.errors['email']">
        You must provide a valid <strong>email</strong>.
      </mat-error>
      <mat-error *ngIf="relevantInvalid(email) && email.errors && email.errors['uniqueUsernameOrEmail']">
        This <strong>email</strong> is already taken.
      </mat-error>
    </mat-form-field>
    <br>
    <mat-form-field appearance="fill">
      <mat-label>Password</mat-label>
      <input type="password" matInput formControlName="password">
      <mat-error *ngIf="relevantInvalid(password) && password.errors && password.errors['required']">
        You must provide a <strong>password</strong>.
      </mat-error>
    </mat-form-field>
    <br>
    <mat-form-field appearance="fill">
      <mat-label>Confirm Password</mat-label>
      <input type="password" matInput formControlName="passwordConfirmation">
      <mat-error *ngIf="relevantInvalid(passwordConfirmation) && passwordConfirmation.errors && passwordConfirmation.errors['required']">
        You must provide a <strong>password confirmation</strong>.
      </mat-error>
      <mat-error *ngIf="relevantInvalid(passwordConfirmation) && passwordConfirmation.errors && passwordConfirmation.errors['compare']">
        <strong>Password</strong> must match <strong>password confirmation</strong>.
      </mat-error>
    </mat-form-field>
    <br>
    <button mat-raised-button color="primary" type="submit" [disabled]="editUserForm.pristine || !editUserForm.valid">Save</button>
  </form>
  <cube-trainer-messages></cube-trainer-messages>
  <cube-trainer-achievement-grants></cube-trainer-achievement-grants>
</div>
`
})
export class UserComponent implements OnInit {
  userId$: Observable<number>;
  userId!: number;
  user!: User;
  editUserForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
	      private readonly activatedRoute: ActivatedRoute,
	      private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p['userId']));
  }

  get userUpdate(): UserUpdate {
    return {
      name: this.name.value,
      email: this.email.value,
      password: this.password.value,
      passwordConfirmation: this.passwordConfirmation.value
    };
  }

  get name() { return this.editUserForm.get('name')!; }

  get email() { return this.editUserForm.get('email')!; }

  get password() { return this.editUserForm.get('password')!; }

  get passwordConfirmation() { return this.editUserForm.get('passwordConfirmation')!; }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  onSubmit() {
    this.usersService.update(this.user!, this.userUpdate).subscribe(r => {
      this.updateUser();
      this.snackBar.open('Update successful!', 'Close');
    });
  }
    
  ngOnInit() {
    this.userId$.subscribe(userId => {
      this.userId = userId;
      this.updateUser();
    });
  }

  updateUser() {
    this.usersService.show(this.userId).subscribe(user => {
      this.user = user;
      this.editUserForm = this.userFormCreator.createUserForm(user);
    });
  }
}
