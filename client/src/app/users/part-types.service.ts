import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Observable } from 'rxjs';
import { PartType } from './part-type.model';

@Injectable({
  providedIn: 'root',
})
export class PartTypesService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<PartType[]> {
    return this.rails.ajax<PartType[]>(HttpVerb.Get, '/part_types', {});
  }
}
