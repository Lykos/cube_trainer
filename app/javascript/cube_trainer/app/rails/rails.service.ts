import snakeCase from 'snake-case-typescript';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
// @ts-ignore
import Rails from '@rails/ujs';
import { HttpVerb } from './http-verb';

class UrlParameterPath {
  path: string[];

  constructor(readonly root: string, path?: string[]) {
    this.path = path || [];
  }

  withSegment(segment: string) {
    const extendedPath: string[] = Object.assign([], this.path);
    extendedPath.push(segment);
    return new UrlParameterPath(this.root, extendedPath);
  }

  withArraySegment() {
    const extendedPath: string[] = Object.assign([], this.path);
    extendedPath.push('[]');
    return new UrlParameterPath(this.root, extendedPath);
  }

  key() {
    return snakeCase(this.root) + this.path.map(s => `[${snakeCase(s)}]`).join('');
  }

  serializeWithValue(value: any) {
    return `${encodeURIComponent(this.key())}=${encodeURIComponent(value)}`;
  }
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  ajax<X>(type: HttpVerb, url: string, data: object): Observable<X> {
    return new Observable<X>((observer) => {
      let subscribed = true;
      const params = this.serializeUrlParams(data);
      Rails.ajax({
	type,
	url,
	dataType: 'json',
	data: params,
	success: (response: X) => {
	  if (subscribed) {
	    observer.next(response);
	    observer.complete();
	  }
	},
	error: (response: any, statusText: string, xhr: any) => { if (subscribed) { observer.error(xhr); } }
      });
      return {
	unsubscribe() {
	  subscribed = false;
	}
      };
    });
  }

  private serializeUrlParams(data: object) {
    const partsAccumulator: string[] = [];
    for (let [key, value] of Object.entries(data)) {
      this.serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
    }
    return partsAccumulator.join('&');
  }

  private serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
    if (typeof value === "object") {
      if (value instanceof Array) {
	for (let subValue of value) {
	  this.serializeUrlParamsPart(subValue, path.withArraySegment(), partsAccumulator);
	}
      } else {
	for (let [key, subValue] of Object.entries(value)) {
	  this.serializeUrlParamsPart(subValue, path.withSegment(key), partsAccumulator);
	}
      }
    } else {
      partsAccumulator.push(path.serializeWithValue(value));
    }
  }
}
