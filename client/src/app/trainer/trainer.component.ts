import { InputItem } from './input-item.model';
import { Component, OnInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { Mode } from '../modes/mode.model';
import { ModesService } from '../modes/modes.service';
import { ActivatedRoute } from '@angular/router';
import { Observable, Subject } from 'rxjs';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html'
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

  onResultsModified() {
    this.resultEventsSubject.next();
  }

  onInputItem(input: InputItem) {
    this.input = input;
  }

  onNumHints(numHints: number) {
    this.numHints = numHints;
  }
}
