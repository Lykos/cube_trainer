import { Component } from '@angular/core';
import { ExecutionOrder, MethodDescription } from '../../utils/cube-stats/method-description';
import { MethodExplorerService } from '../method-explorer.service';
import { AlgCountsData } from '../alg-counts-data.model';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  readonly expectedAlgCountsData$: Observable<AlgCountsData>;
  
  constructor(private readonly methodExplorerService: MethodExplorerService) {
    this.expectedAlgCountsData$ = this.methodExplorerService.expectedAlgCounts(this.methodDescription);
  }

  get executionOrder() {
    return ExecutionOrder.CE;
  }

  get methodDescription(): MethodDescription {
    return {executionOrder: this.executionOrder};
  }
}
