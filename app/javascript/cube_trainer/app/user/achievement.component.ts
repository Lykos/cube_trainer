import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'achievement',
  template: `
<mat-card>
  <mat-card-title>{{name}}</mat-card-title>
  <mat-card-content>
    {{description}}
  </mat-card-content>
  <mat-card-actions>
    <button mat-raised-button color="primary" (click)="onAll()">All Achievements</button>
  </mat-card-actions>
</mat-card>
`
})
export class AchievementComponent implements OnInit {
  achievementId$: Observable<number>;
  achievement: Achievement | undefined = undefined;

  constructor(private readonly achievementsService: AchievementsService,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.achievementId$ = this.activatedRoute.params.pipe(map(p => p.achievementId));
  }

  get name() {
    return this.achievement?.name;
  }

  get description() {
    return this.achievement?.description;
  }

  onAll() {
    this.router.navigate(['/achievements']);
  }

  ngOnInit() {
    this.achievementId$.subscribe(achievementId => {
      this.achievementsService.show(achievementId).subscribe((achievement: Achievement) =>
	this.achievement = achievement);
    });
  }
}
