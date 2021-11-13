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

  isLetterSchemeNameTaken(letterSchemeName: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/letter_scheme_name_exists_for_user', {letterSchemeName});
  }

  list(): Observable<LetterScheme[]> {
    return this.rails.ajax<LetterScheme[]>(HttpVerb.Get, '/letter_schemes', {});
  }

  show(modeId: number): Observable<LetterScheme> {
    return this.rails.ajax<LetterScheme>(HttpVerb.Get, `/letter_schemes/${modeId}`, {});
  }

  destroy(modeId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/letter_schemes/${modeId}`, {});
  }

  create(letterScheme: NewLetterScheme): Observable<LetterScheme> {
    return this.rails.ajax<LetterScheme>(HttpVerb.Post, '/letter_schemes', {letterScheme});
  }
}
