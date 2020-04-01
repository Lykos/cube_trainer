import { RailsService } from './rails.service';
import { Injectable } from '@angular/core';
// @ts-ignore
import HttpMethodsEnum from 'http-methods-enum';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  path(mode: number, method: string) {
    return `/timer/${mode}/${method}`;
  }

  nextInput(mode: number) {
    this.rails.ajax(HttpMethodsEnum.Post, this.path(mode, 'next_input'), {});
  }
}
