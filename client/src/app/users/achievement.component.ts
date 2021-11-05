import { Component, OnInit } from '@angular/core';
import { AchievementsService } from './achievements.service';
import { Achievement } from './achievement';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-achievement',
  templateUrl: './achievement.component.html'
})
export class AchievementComponent implements OnInit {
  achievementKey$: Observable<string>;
  achievement: Achievement | undefined = undefined;

  constructor(private readonly achievementsService: AchievementsService,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.achievementKey$ = this.activatedRoute.params.pipe(map(p => p['achievementKey']));
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
    this.achievementKey$.subscribe(achievementKey => {
      this.achievementsService.show(achievementKey).subscribe((achievement: Achievement) =>
	this.achievement = achievement);
    });
  }
}
