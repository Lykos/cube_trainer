import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  constructor(private readonly rails: RailsService) {}

  login(name: string, password: string) {
    return this.rails.ajax<void>(HttpVerb.Post, '/login', {name, password});
  }

  logout() {
    return this.rails.ajax<void>(HttpVerb.Post, '/logout', {});
  }

  create(name: string, password: string, passwordConfirmation: string, admin: boolean) {
    return this.rails.ajax<void>(HttpVerb.Post, 'users/create', {name, password, passwordConfirmation, admin});
  }
}
