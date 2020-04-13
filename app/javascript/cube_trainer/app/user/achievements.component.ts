import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';

@Component({
  selector: 'achievements',
  template: `
<div>
  <h2>Achievements</h2>
  <div>
    <table mat-table [dataSource]="modes">
      <mat-text-column name="name"></mat-text-column>
      <mat-text-column name="description"></mat-text-column>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let achievement; columns: columnsToDisplay"></tr>
    </table>
  </div>
</div>
`
})
export class AchievementsComponent implements OnInit {
  achievements: Achievement[] = [];
  columnsToDisplay = ['timestamp', 'achievement'];

  constructor(private readonly achievementsService: AchievementsService) {}

  ngOnInit() {
    this.achievementsService.list().subscribe((achievements: Achievement[]) =>
      this.achievements = achievements);
  }
}
