import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatTableModule } from '@angular/material/table';
import { CommonModule } from '@angular/common';
import { AlgCountsTableComponent } from './alg-counts-table/alg-counts-table.component';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MethodExplorerComponent } from './method-explorer/method-explorer.component';
import { SharedModule } from '../shared/shared.module';
import { MethodExplorerService } from './method-explorer.service';
import { MethodDescriptionFormComponent } from './method-description-form/method-description-form.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatCardModule } from '@angular/material/card';
import { HierarchicalAlgSetSelectComponent } from './hierarchical-alg-set-select/hierarchical-alg-set-select.component';

@NgModule({
  declarations: [
    MethodExplorerComponent,
    AlgCountsTableComponent,
    MethodDescriptionFormComponent,
    HierarchicalAlgSetSelectComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    MatProgressSpinnerModule,
    BrowserModule,
    BrowserAnimationsModule,
    MatTableModule,
    FormsModule,
    ReactiveFormsModule,
    MatCheckboxModule,
    MatSnackBarModule,
    MatInputModule,
    MatButtonModule,
    MatFormFieldModule,
    MatSelectModule,
    MatCardModule,
  ],
  exports: [
    MethodExplorerComponent,
  ],
  providers: [
    MethodExplorerService,
  ]
})
export class MethodExplorerModule { }
