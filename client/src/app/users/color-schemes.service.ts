import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { NewColorScheme } from './new-color-scheme.model';
import { ColorScheme } from './color-scheme.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ColorSchemesService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<ColorScheme[]> {
    return this.rails.ajax<ColorScheme[]>(HttpVerb.Get, '/color_schemes', {});
  }

  show(modeId: number): Observable<ColorScheme> {
    return this.rails.ajax<ColorScheme>(HttpVerb.Get, `/color_schemes/${modeId}`, {});
  }

  destroy(modeId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/color_schemes/${modeId}`, {});
  }

  create(colorScheme: NewColorScheme): Observable<ColorScheme> {
    return this.rails.ajax<ColorScheme>(HttpVerb.Post, '/color_schemes', {colorScheme});
  }
}
