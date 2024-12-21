import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { map } from 'rxjs/operators';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'cube-trainer-confirm-email',
  templateUrl: './confirm-email.component.html',
  imports: [MatButtonModule],
})
export class ConfirmEmailComponent implements OnInit {
  // Initially both are false and once we know, we set one.
  // TODO: Clean this up
  success = false;
  failed = false;

  constructor(private readonly activatedRoute: ActivatedRoute) {}  

  ngOnInit() {
    this.activatedRoute.queryParams.pipe(map(p => p['account_confirmation_success'])).subscribe(success => {
      this.success = success;
      this.failed = !success;
    });
  }
}
