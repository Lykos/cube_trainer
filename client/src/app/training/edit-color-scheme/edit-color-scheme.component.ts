import { Component, OnInit } from '@angular/core';
import { ColorScheme } from '../color-scheme.model';
import { Optional } from '@utils/optional';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { selectColorScheme, selectInitialLoadLoading } from '@store/color-scheme.selectors';
import { initialLoad } from '@store/color-scheme.actions';
import { SharedModule } from '@shared/shared.module';
import { EditColorSchemeFormComponent } from '../edit-color-scheme-form/edit-color-scheme-form.component';

@Component({
  selector: 'cube-trainer-edit-color-scheme',
  templateUrl: './edit-color-scheme.component.html',
  imports: [EditColorSchemeFormComponent, SharedModule],
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
