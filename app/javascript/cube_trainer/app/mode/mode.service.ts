import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Mode } from './mode';

@Injectable({
  providedIn: 'root',
})
export class ModeService {
  constructor(private readonly rails: RailsService) {}

  list() {
    return this.rails.ajax<Mode[]>(HttpVerb.Get, '/modes', {});
  }

  create(mode: Mode) {
    return this.rails.ajax<Mode>(HttpVerb.Post, '/modes', {mode});
  }
}
