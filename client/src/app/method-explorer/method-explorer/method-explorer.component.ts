import { Component } from '@angular/core';
import { expectedAlgs, ExecutionOrder } from '../../utils/cube-stats';

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
    return expectedAlgs(this.methodDescription).toFixed(2);
  }
}
