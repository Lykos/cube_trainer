import { BackendActionErrorDialogComponent } from './backend-action-error-dialog/backend-action-error-dialog.component';
import { BackendActionErrorPipe } from './backend-action-error.pipe';
import { DurationPipe } from './duration.pipe';
import { ErrorPipe } from './error.pipe';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { InstantPipe } from './instant.pipe';
import { FluidInstantPipe } from './fluid-instant.pipe';
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
import { BackendActionLoadErrorComponent } from './backend-action-load-error/backend-action-load-error.component';
import { GithubErrorNoteComponent } from './github-error-note/github-error-note.component';

@NgModule({
    imports: [
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
        BackendActionErrorDialogComponent,
        BackendActionErrorPipe,
        BackendActionLoadErrorComponent,
        DurationPipe,
        ErrorPipe,
        InstantPipe,
        FluidInstantPipe,
        OrErrorPipe,
        ValuePipe,
        GithubErrorNoteComponent,
    ],
    exports: [
        BackendActionErrorPipe,
        BackendActionLoadErrorComponent,
        DurationPipe,
        ErrorPipe,
        FormsModule,
        InstantPipe,
        FluidInstantPipe,
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
