import { InputItem } from './input-item';
import { Component, OnInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { Mode } from '../modes/mode';
import { ModesService } from '../modes/modes.service';
import { ActivatedRoute } from '@angular/router';
import { Observable, Subject } from 'rxjs';

@Component({
  selector: 'cube-trainer-trainer',
  template: `
<div layout="row" layout-sm="column">
  <div flex>
    <cube-trainer-trainer-input [input]="input" [mode]="mode" [numHints]="numHints" *ngIf="mode && input"></cube-trainer-trainer-input>
    <cube-trainer-stopwatch [mode]="mode" (inputItem)="onInputItem($event)" (resultSaved)="onResultSaved()" (numHints)="onNumHints($event)" *ngIf="mode"></cube-trainer-stopwatch>
  </div>
  <div flex>
    <cube-trainer-results-table [resultEvents$]="resultEventsSubject.asObservable()"></cube-trainer-results-table>
  </div>
  <div flex>
    <cube-trainer-stats-table [statEvents$]="resultEventsSubject.asObservable()"></cube-trainer-stats-table>
  </div>
</div>
`
})
export class TrainerComponent implements OnInit {
  input: InputItem | undefined = undefined;
  numHints = 0;
  private modeId$: Observable<number>;
  mode: Mode | undefined = undefined;
  resultEventsSubject = new Subject<void>();

  constructor(private readonly modesService: ModesService,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p['modeId']));
  }

  ngOnInit() {
    this.modeId$.subscribe(modeId =>
      this.modesService.show(modeId).subscribe(mode => this.mode = mode));
  }

  onResultSaved() {
    this.resultEventsSubject.next();
  }

  onInputItem(input: InputItem) {
    this.input = input;
  }

  onNumHints(numHints: number) {
    this.numHints = numHints;
  }
}
