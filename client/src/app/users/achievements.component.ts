import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';
import { Router } from '@angular/router';

@Component({
  selector: 'achievements',
  template: `
<div>
  <h2>All Achievements</h2>
  <div>
    <table mat-table class="mat-elevation-z2" [dataSource]="achievements">
      <ng-container matColumnDef="name">
        <th mat-header-cell *matHeaderCellDef> Name </th>
        <td mat-cell *matCellDef="let achievement" matTooltip="{{achievement.description}}">
          {{achievement.name}}
        </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let achievement; columns: columnsToDisplay" (click)="onClick(achievement)"></tr>
    </table>
  </div>
</div>
`,
  styles: [`
table {
  width: 100%;
}
`]
})
export class AchievementsComponent implements OnInit {
  achievements: Achievement[] = [];
  columnsToDisplay = ['name'];

  constructor(private readonly achievementsService: AchievementsService,
	      private readonly router: Router) {}

  onClick(achievement: Achievement) {
    this.router.navigate([`/achievements/${achievement.key}`]);
  }

  ngOnInit() {
    this.achievementsService.list().subscribe((achievements: Achievement[]) =>
      this.achievements = achievements);
  }
}
