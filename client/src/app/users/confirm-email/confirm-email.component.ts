import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { ActivatedRoute } from '@angular/router';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';

@Component({
  selector: 'cube-trainer-confirm-email',
  templateUrl: './confirm-email.component.html',
})
export class ConfirmEmailComponent implements OnInit {
  confirmed = false;
  failed = false;

  constructor(private readonly usersService: UsersService,
	      private readonly activatedRoute: ActivatedRoute) {}  

  ngOnInit() {
    this.activatedRoute.params.pipe(map(p => p['token'])).subscribe(token => {
      this.usersService.confirmEmail(token).pipe(
        map(r => true),
        catchError(err => of(false)),
      ).subscribe(success => {
        this.confirmed = success;
        this.failed = !success;
      });
    });
  }
}
