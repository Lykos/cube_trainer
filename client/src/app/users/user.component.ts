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
  templateUrl: './user.component.html'
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
