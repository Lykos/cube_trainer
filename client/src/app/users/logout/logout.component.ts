import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';

@Component({
  selector: 'cube-trainer-logout',
  templateUrl: './logout.component.html',
})
export class LogoutComponent implements OnInit {
  success = false;
  failure = false;

  constructor(private readonly usersService: UsersService) {}  

  ngOnInit() {
    this.usersService.logout().pipe(
      map(value => true),
      catchError(err => of(false)),
    ).subscribe((success) => {
      this.success = success;
      this.failure = !success;
    });
  }
}
