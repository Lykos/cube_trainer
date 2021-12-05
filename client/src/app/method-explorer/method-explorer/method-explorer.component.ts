import { Component } from '@angular/core';
import { expectedAlgCounts, ExecutionOrder } from '../../utils/cube-stats/cube-stats';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  get executionOrder() {
    return ExecutionOrder.EC;
  }

  get methodDescription() {
    return {executionOrder: this.executionOrder};
  }
  
  get expectedAlgs() {
    return expectedAlgCounts(this.methodDescription).total.toFixed(2);
  }
}
