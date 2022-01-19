import { Component } from '@angular/core';
import { achievements } from '../achievements.const';

@Component({
  selector: 'cube-trainer-achievements',
  templateUrl: './achievements.component.html',
  styleUrls: ['./achievements.component.css']
})
export class AchievementsComponent {
  achievements = achievements;
  columnsToDisplay = ['name'];
}
