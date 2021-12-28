import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { NewColorScheme } from './new-color-scheme.model';
import { ColorScheme } from './color-scheme.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ColorSchemesService {
  constructor(private readonly rails: RailsService) {}

  show(): Observable<ColorScheme> {
    return this.rails.get<ColorScheme>('/color_scheme', {});
  }

  destroy(): Observable<void> {
    return this.rails.delete<void>('/color_scheme', {});
  }

  create(colorScheme: NewColorScheme): Observable<ColorScheme> {
    return this.rails.post<ColorScheme>('/color_scheme', {colorScheme});
  }
}
