import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
// @ts-ignore
import Rails from '@rails/ujs';
// @ts-ignore
import HttpMethodsEnum from 'http-methods-enum';

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

  key() {
    return this.root + this.path.map(s => `[${s}]`).join('');
  }

  serializeWithValue(value: any) {
    return `${encodeURIComponent(this.key())}=${encodeURIComponent(value)}`;
  }
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  ajax<X>(type: HttpMethodsEnum, url: string, data: object): Observable<X> {
    return new Observable<X>((observer) => {
      const xhr = Rails.ajax({
	type,
	url,
	data: this.serializeUrlParams(data),
	success: (response: X) => { observer.next(response); },
	error: (response: any) => { observer.error(response); }
      });
      return {
	unsubscribe() {
	  xhr.abort();
	}
      };
    });
  }

  private serializeUrlParams(data: object) {
    const partsAccumulator: string[] = [];
    for (let [key, value] of Object.entries(data)) {
      this.serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
    }
    return partsAccumulator.join('');
  }

  private serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
    if (typeof value === "object") {
      for (let [key, subValue] of Object.entries(value)) {
	this.serializeUrlParamsPart(subValue, path.withSegment(key), partsAccumulator);
      }
    } else {
      partsAccumulator.push(path.serializeWithValue(value));
    }
  }
}
