import { Component, OnInit } from '@angular/core';
import { ColorScheme } from '../color-scheme.model';
import { Optional } from '@utils/optional';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { selectColorScheme, selectInitialLoadLoading } from '@store/color-scheme.selectors';
import { initialLoad } from '@store/color-scheme.actions';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { EditColorSchemeFormComponent } from '../edit-color-scheme-form/edit-color-scheme-form.component';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'cube-trainer-edit-color-scheme',
  templateUrl: './edit-color-scheme.component.html',
  imports: [EditColorSchemeFormComponent, AsyncPipe, MatProgressSpinnerModule],
})
export class EditColorSchemeComponent implements OnInit {
  existingColorScheme$: Observable<Optional<ColorScheme>>;
  initialLoadLoading$: Observable<boolean>;

  constructor(private readonly store: Store) {
    this.existingColorScheme$ = this.store.select(selectColorScheme);
    this.initialLoadLoading$ = this.store.select(selectInitialLoadLoading);
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
}
