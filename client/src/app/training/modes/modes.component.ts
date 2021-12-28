import { Component, OnInit } from '@angular/core';
import { Mode } from '../mode.model';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { initialLoad, deleteClick } from '@store/modes.actions';
import { selectModes, selectInitialLoadOrDestroyLoading, selectInitialLoadError } from '@store/modes.selectors';

@Component({
  selector: 'cube-trainer-modes',
  templateUrl: './modes.component.html',
  styleUrls: ['./modes.component.css']
})
export class ModesComponent implements OnInit {
  modes$: Observable<readonly Mode[]>;
  loading$: Observable<boolean>;
  error$: Observable<any>;
  columnsToDisplay = ['name', 'numResults', 'use', 'delete'];

  constructor(private readonly store: Store) {
    this.modes$ = this.store.select(selectModes);
    this.loading$ = this.store.select(selectInitialLoadOrDestroyLoading);
    this.error$ = this.store.select(selectInitialLoadError);
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
  
  onDelete(mode: Mode) {
    this.store.dispatch(deleteClick({ mode }));
  } 

  routerLink(mode: Mode) {
    return `/training/${mode.id}`;
  }
}
