import { InputItem } from './input-item';
import { Component } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subject } from 'rxjs';

@Component({
  selector: 'trainer',
  template: `
<div layout="row" layout-sm="column">
  <div flex>
    <trainer-input [input]="input" [modeId$]="modeId$" [numHints]="numHints" *ngIf="input"></trainer-input>
    <stopwatch [modeId$]="modeId$" (inputItem)="onInputItem($event)" (resultSaved)="onResultSaved()" (numHints)="onNumHints($event)"></stopwatch>
  </div>
  <div flex>
    <results-table [resultEvents$]="resultEventsSubject.asObservable()"></results-table>
  </div>
  <div flex>
    <stats-table [statEvents$]="resultEventsSubject.asObservable()"></stats-table>
  </div>
</div>
`,
  styles: [`
.stopwatch-time {
  font-size: xxx-large;
}
`]
})
export class TrainerComponent {
  input: InputItem | undefined = undefined;
  numHints = 0;
  modeId$: Observable<number>;
  resultEventsSubject = new Subject<void>();

  constructor(activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p.modeId));
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
