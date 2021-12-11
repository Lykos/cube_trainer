import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatTableModule } from '@angular/material/table';
import { CommonModule } from '@angular/common';
import { AlgCountsTableComponent } from 'alg-counts-table/alg-counts-table.component';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MethodExplorerComponent } from './method-explorer/method-explorer.component';
import { SharedModule } from '../shared/shared.module';
import { MethodExplorerService } from './method-explorer.service';

@NgModule({
  declarations: [
    MethodExplorerComponent,
    AlgCountsTableComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    MatProgressSpinnerModule,
    BrowserModule,
    BrowserAnimationsModule,
    MatTableModule,
  ],
  exports: [
    MethodExplorerComponent,
  ],
  providers: [
    MethodExplorerService,
  ]
})
export class MethodExplorerModule { }
