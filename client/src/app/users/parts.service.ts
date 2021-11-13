import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { PartType } from './part-type.model';

function parsePartType(rawPartType: any): PartType[] {
  return {
    name: raw
  };
}

@Injectable({
  providedIn: 'root',
})
export class LetterSchemesService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<Part[]> {
    return this.rails.ajax<LetterScheme[]>(HttpVerb.Get, '/part_types', {}).pipe(map(partTypes parseParts));
  }
}
