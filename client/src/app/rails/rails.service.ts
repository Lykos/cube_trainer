import { camelCaseToSnakeCase } from '../utils/case';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient, HttpParams } from '@angular/common/http';
import { HttpVerb } from './http-verb';
import { environment } from './../../environments/environment';

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
    extendedPath.push('');
    return new UrlParameterPath(this.root, extendedPath);
  }

  key() {
    return camelCaseToSnakeCase(this.root) + this.path.map(s => `[${camelCaseToSnakeCase(s)}]`).join('');
  }
  
  serializeWithValue(value: any) {
    return `${encodeURIComponent(this.key())}=${encodeURIComponent(value)}`;
  }
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  constructor(private readonly http: HttpClient) {}

  ajax<X>(type: HttpVerb, relativeUrl: string, data: object): Observable<X> {
    const url = environment.apiPrefix + relativeUrl;
    const params = this.serializeUrlParams(data);
    // TODO clean this up, this is a relict from when we used railsujs where you needed to pass the method.
    switch (type) {
      case HttpVerb.Get:
        return this.http.get<X>(url, {
          observe: 'body',
          responseType: 'json',
          params,
        });
      case HttpVerb.Post:
        return this.http.post<X>(url, params, {
          observe: 'body',
          responseType: 'json',
        });
      case HttpVerb.Put:
        return this.http.put<X>(url, params, {
          observe: 'body',
          responseType: 'json',
        });
      case HttpVerb.Patch:
        return this.http.patch<X>(url, params, {
          observe: 'body',
          responseType: 'json',
        });
      case HttpVerb.Delete:
        return this.http.delete<X>(url, {
          observe: 'body',
          responseType: 'json',
          params,
        });
      case HttpVerb.Head:
        return this.http.head<X>(url, {
          observe: 'body',
          responseType: 'json',
          params,
        });
    }
  }

  private serializeUrlParams(data: object): HttpParams {
    const partsAccumulator: string[] = []
    for (let [key, value] of Object.entries(data)) {
      this.serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
    }
    return new HttpParams({fromString: partsAccumulator.join('&')});
  }

  private serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
    if (value === undefined || value === null) {
      return;
    } else if (typeof value === "object") {
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
