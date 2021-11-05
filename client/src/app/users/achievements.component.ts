import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';
import { Router } from '@angular/router';

@Component({
  selector: 'cube-trainer-achievements',
  templateUrl: './achievements.component.html',
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
