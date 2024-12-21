import { MatSnackBar } from '@angular/material/snack-bar';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { UsersService } from '../users.service';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'cube-trainer-reset-password',
  templateUrl: './reset-password.component.html',
  styleUrls: ['./reset-password.component.css'],
  imports: [MatFormFieldModule, FormsModule, ReactiveFormsModule, MatButtonModule, MatInputModule],
})
export class ResetPasswordComponent implements OnInit {
  form!: FormGroup;

  constructor(private readonly formBuilder: FormBuilder,
	      private readonly snackBar: MatSnackBar,
              private readonly usersService: UsersService) {}

  ngOnInit() {
    this.form = this.formBuilder.group({
      email: ['']
    });
  }

  onSubmit() {
    const email = this.form.get('email')!.value;
    this.usersService.resetPassword(email).subscribe(() => {
      this.snackBar.open('Email sent!', 'Close');      
    });
  }
}
