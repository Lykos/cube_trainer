import { Component, OnInit } from '@angular/core';
import { AchievementGrantsService } from './achievement-grants.service';
import { AchievementGrant } from './achievement-grant';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'achievement-grants',
  template: `
<div>
  <h2>Achievements</h2>
  <div>
    <table mat-table class="mat-elevation-z2" [dataSource]="achievementGrants">
      <ng-container matColumnDef="timestamp">
        <th mat-header-cell *matHeaderCellDef> Timestamp </th>
        <td mat-cell *matCellDef="let achievementGrant"> {{achievementGrant.timestamp | instant}} </td>
      </ng-container>
      <ng-container matColumnDef="achievement">
        <th mat-header-cell *matHeaderCellDef> Achievement </th>
        <td mat-cell *matCellDef="let achievementGrant"> {{achievementGrant.achievement.name}} </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let achievementGrant; columns: columnsToDisplay" (click)="onClick(achievementGrant)"></tr>
    </table>
  </div>
</div>
`
})
export class AchievementGrantsComponent implements OnInit {
  userId$: Observable<number>;
  achievementGrants: AchievementGrant[] = [];
  columnsToDisplay = ['timestamp', 'achievement'];

  constructor(private readonly achievementGrantsService: AchievementGrantsService,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p.userId));
  }

  onClick(achievementGrant: AchievementGrant) {
    this.router.navigate([`/achievements/${achievementGrant.achievement.key}`]);
  }

  ngOnInit() {
    this.userId$.subscribe(userId => {
      this.achievementGrantsService.list(userId).subscribe((achievementGrants: AchievementGrant[]) =>
	this.achievementGrants = achievementGrants);
    });
  }
}
