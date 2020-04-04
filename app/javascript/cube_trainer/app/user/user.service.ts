import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  create(name: string, password: string, passwordConfirmation: string, admin: boolean) {
    return this.rails.ajax<void>(HttpVerb.Post, 'users/create', {name, password, passwordConfirmation, admin});
  }
}
