import { MatSnackBar } from '@angular/material/snack-bar';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { UsersService } from '../users.service';

@Component({
  selector: 'cube-trainer-reset-password',
  templateUrl: './reset-password.component.html',
  styleUrls: ['./reset-password.component.css']
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
