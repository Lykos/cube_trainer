import { Component } from '@angular/core';
import { MethodDescription } from '../../utils/cube-stats/method-description';
import { MethodExplorerService } from '../method-explorer.service';
import { AlgCountsData } from '../alg-counts-data.model';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css']
})
export class MethodExplorerComponent {
  expectedAlgsData$: Observable<AlgCountsData> | undefined = undefined;
  
  constructor(private readonly methodExplorerService: MethodExplorerService) {}

  calculate(methodDescription: MethodDescription) {
    this.expectedAlgsData$ = this.methodExplorerService.expectedAlgCounts(methodDescription);
  }
}
