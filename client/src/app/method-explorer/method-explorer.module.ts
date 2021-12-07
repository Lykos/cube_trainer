import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MethodExplorerComponent } from './method-explorer/method-explorer.component';
import { SharedModule } from '../shared/shared.module';
import { MethodExplorerService } from './method-explorer.service';

@NgModule({
  declarations: [
    MethodExplorerComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    MatProgressSpinnerModule,
  ],
  exports: [
    MethodExplorerComponent,
  ],
  providers: [
    MethodExplorerService,
  ]
})
export class MethodExplorerModule { }
