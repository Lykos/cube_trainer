import { Component } from '@angular/core';
import { expectedAlgs, ExecutionOrder } from '../../utils/cube-stats';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  get expectedAlgs() {
    return expectedAlgs({executionOrder: ExecutionOrder.EC});
  }
}
