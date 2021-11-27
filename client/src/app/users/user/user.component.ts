import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { User } from '../user.model';
import { FormGroup, AbstractControl } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserUpdate } from '../user-update.model';
import { UserFormCreator } from '../user-form-creator.service';
import { Router } from '@angular/router';

@Component({
  selector: 'cube-trainer-user',
  templateUrl: './user.component.html'
})
export class UserComponent implements OnInit {
  user!: User;
  editUserForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
	      private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

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
    this.usersService.update(this.userUpdate).subscribe(r => {
      this.updateUser();
      this.snackBar.open('Update successful!', 'Close');
    });
  }
    
  ngOnInit() {
    this.updateUser();
  }

  onCreateColorScheme() {
    this.router.navigate(['/color_schemes/new']);
  }

  onCreateLetterScheme() {
    this.router.navigate(['/letter_schemes/new']);
  }

  updateUser() {
    this.usersService.show().subscribe(user => {
      this.user = user;
      this.editUserForm = this.userFormCreator.createUserForm(user);
    });
  }
}
