import { BackendActionErrorDialogComponent } from './backend-action-error-dialog/backend-action-error-dialog.component';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { DurationPipe } from './duration.pipe';
import { ErrorPipe } from './error.pipe';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { InstantPipe } from './instant.pipe';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatRippleModule } from '@angular/material/core';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatStepperModule } from '@angular/material/stepper';
import { MatTableModule } from '@angular/material/table';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgModule } from '@angular/core';
import { OrErrorPipe } from './or-error.pipe';
import { RouterModule } from '@angular/router';
import { RxReactiveFormsModule } from '@rxweb/reactive-form-validators';
import { ValuePipe } from './value.pipe';

@NgModule({
  declarations: [
    InstantPipe,
    DurationPipe,
    OrErrorPipe,
    ValuePipe,
    ErrorPipe,
    BackendActionErrorDialogComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatPaginatorModule,
    MatProgressSpinnerModule,
    MatRippleModule,
    MatSelectModule,
    MatSnackBarModule,
    MatStepperModule,
    MatTableModule,
    MatTooltipModule,
    ReactiveFormsModule,
    RouterModule,
    RxReactiveFormsModule,
  ],
  exports: [
    DurationPipe,
    ErrorPipe,
    InstantPipe,
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    MatButtonModule,
    MatCardModule,
    MatCheckboxModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatPaginatorModule,
    MatProgressSpinnerModule,
    MatRippleModule,
    MatSelectModule,
    MatSnackBarModule,
    MatStepperModule,
    MatTableModule,
    MatTooltipModule,
    OrErrorPipe,
    ReactiveFormsModule,
    RouterModule,
    RxReactiveFormsModule,
    ValuePipe,
  ],
})
export class SharedModule {}
