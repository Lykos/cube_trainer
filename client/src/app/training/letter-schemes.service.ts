import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { NewLetterScheme } from './new-letter-scheme.model';
import { LetterScheme } from './letter-scheme.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class LetterSchemesService {
  constructor(private readonly rails: RailsService) {}

  show(): Observable<LetterScheme> {
    return this.rails.get<LetterScheme>('/letter_scheme', {});
  }

  destroy(): Observable<void> {
    return this.rails.delete<void>('/letter_scheme', {});
  }

  create(letterScheme: NewLetterScheme): Observable<LetterScheme> {
    return this.rails.post<LetterScheme>('/letter_scheme', {letterScheme});
  }
}
