import { Injectable } from '@angular/core';
import { RailsService } from '../core/rails.service';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DumpsService {
  constructor(private readonly rails: RailsService) {}

  show(): Observable<Blob> {
    return this.rails.getBlob('dump');
  }
}
