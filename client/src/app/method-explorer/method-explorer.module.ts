import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MethodExplorerComponent } from './method-explorer/method-explorer.component';
import { MethodExplorerService } from './method-explorer.service';

@NgModule({
  declarations: [
    MethodExplorerComponent,
  ],
  imports: [
    CommonModule,
  ],
  exports: [
    MethodExplorerComponent,
  ],
  providers: [
    MethodExplorerService,
  ]
})
export class MethodExplorerModule { }
