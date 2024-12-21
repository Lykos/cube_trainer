import { PartTypesService } from '../part-types.service';
import { Component, OnInit } from '@angular/core';
import { LetterScheme } from '../letter-scheme.model';
import { Optional } from '@utils/optional';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { PartType } from '../part-type.model';
import { selectLetterScheme, selectInitialLoadLoading } from '@store/letter-scheme.selectors';
import { initialLoad } from '@store/letter-scheme.actions';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatInputModule } from '@angular/material/input';
import { EditLetterSchemeFormComponent } from '../edit-letter-scheme-form/edit-letter-scheme-form.component';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'cube-trainer-edit-letter-scheme',
  templateUrl: './edit-letter-scheme.component.html',
  imports: [EditLetterSchemeFormComponent, AsyncPipe, MatProgressSpinnerModule, MatInputModule],
})
export class EditLetterSchemeComponent implements OnInit {
  existingLetterScheme$: Observable<Optional<LetterScheme>>;
  initialLoadLoading$: Observable<boolean>;
  partTypes$: Observable<PartType[]>;

  constructor(
    private readonly store: Store,
    private readonly partTypesService: PartTypesService,
  ) {
    this.existingLetterScheme$ = this.store.select(selectLetterScheme);
    this.initialLoadLoading$ = this.store.select(selectInitialLoadLoading);
    this.partTypes$ = this.partTypesService.list();
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
}
