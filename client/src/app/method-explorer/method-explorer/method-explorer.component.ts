import { Component } from '@angular/core';
import { ExecutionOrder, MethodDescription } from '../../utils/cube-stats/method-description';
import { MethodExplorerService } from '../method-explorer.service';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  readonly expectedTotalAlgs$: Observable<string>;

  constructor(private readonly methodExplorerService: MethodExplorerService) {
    this.expectedTotalAlgs$ = this.methodExplorerService.expectedAlgCounts(this.methodDescription).pipe(
      map(algCounts => algCounts.total.toFixed(2))
    );
  }

  get executionOrder() {
    return ExecutionOrder.EC;
  }

  get methodDescription(): MethodDescription {
    return {executionOrder: this.executionOrder};
  }
}
