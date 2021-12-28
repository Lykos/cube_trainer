import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '@core/http-verb';
import { NewColorScheme } from './new-color-scheme.model';
import { ColorScheme } from './color-scheme.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ColorSchemesService {
  constructor(private readonly rails: RailsService) {}

  show(): Observable<ColorScheme> {
    return this.rails.ajax<ColorScheme>(HttpVerb.Get, '/color_scheme', {});
  }

  destroy(): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, '/color_scheme', {});
  }

  create(colorScheme: NewColorScheme): Observable<ColorScheme> {
    return this.rails.ajax<ColorScheme>(HttpVerb.Post, '/color_scheme', {colorScheme});
  }
}
