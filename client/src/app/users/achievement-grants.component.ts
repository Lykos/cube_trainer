import { Component, OnInit } from '@angular/core';
import { AchievementGrantsService } from './achievement-grants.service';
import { AchievementGrant } from './achievement-grant.model';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-achievement-grants',
  templateUrl: './achievement-grants.component.html',
  styleUrls: ['./achievement-grants.component.css']
})
export class AchievementGrantsComponent implements OnInit {
  userId$: Observable<number>;
  achievementGrants: AchievementGrant[] = [];
  columnsToDisplay = ['achievement', 'timestamp'];

  constructor(private readonly achievementGrantsService: AchievementGrantsService,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p['userId']));
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
