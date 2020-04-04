import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { NewUser } from '../new_user';
@Injectable({
  providedIn: 'root',
})
export class UserService {
  constructor(private readonly rails: RailsService) {}

  create(newUser: NewUser) {
    return this.rails.ajax<void>(HttpVerb.Post, 'users', {user: newUser});
  }
}
