import { Component } from '@angular/core';
import { ExecutionOrder, MethodDescription } from '../../utils/cube-stats/cube-stats';
import { MethodExplorerService } from '../method-explorer.service';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  constructor(private readonly methodExplorerService: MethodExplorerService) {}

  get executionOrder() {
    return ExecutionOrder.EC;
  }

  get methodDescription(): MethodDescription {
    return {executionOrder: this.executionOrder};
  }
  
  get expectedTotalAlgs$() {
    return this.methodExplorerService.expectedAlgCounts(this.methodDescription).pipe(
      map(algCounts => algCounts.total.toFixed(2))
    );
  }
}
