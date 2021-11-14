import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { NewLetterScheme } from './new-letter-scheme.model';
import { LetterScheme } from './letter-scheme.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class LetterSchemesService {
  constructor(private readonly rails: RailsService) {}

  show(): Observable<LetterScheme> {
    return this.rails.ajax<LetterScheme>(HttpVerb.Get, '/letter_scheme', {});
  }

  destroy(): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, '/letter_scheme', {});
  }

  create(letterScheme: NewLetterScheme): Observable<LetterScheme> {
    return this.rails.ajax<LetterScheme>(HttpVerb.Post, '/letter_scheme', {letterScheme});
  }
}
