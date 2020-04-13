import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';
import { Router } from '@angular/router';

@Component({
  selector: 'achievements',
  template: `
<div>
  <h2>Achievements</h2>
  <div>
    <table mat-table [dataSource]="achievements">
      <mat-text-column name="name"></mat-text-column>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let achievement; columns: columnsToDisplay" (click)="onClick(achievement)"></tr>
    </table>
  </div>
</div>
`
})
export class AchievementsComponent implements OnInit {
  achievements: Achievement[] = [];
  columnsToDisplay = ['name'];

  constructor(private readonly achievementsService: AchievementsService,
	      private readonly router: Router) {}

  onClick(achievement: Achievement) {
    this.router.navigate([`/achievements/${achievement.id}`]);
  }

  ngOnInit() {
    this.achievementsService.list().subscribe((achievements: Achievement[]) =>
      this.achievements = achievements);
  }
}
