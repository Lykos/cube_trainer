import { camelCaseToSnakeCase, camelCaseifyFields } from '@utils/case';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '@environment';

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

function constructUrl(relativeUrl: string) {
  return `${environment.apiPrefix}${relativeUrl}`;
}

function serializeUrlParams(data: object): HttpParams {
  const partsAccumulator: string[] = []
  for (let [key, value] of Object.entries(data)) {
    serializeUrlParamsPart(value, new UrlParameterPath(key), partsAccumulator);
  }
  return new HttpParams({fromString: partsAccumulator.join('&')});
}

function serializeUrlParamsPart(value: any, path: UrlParameterPath, partsAccumulator: string[]) {
  if (value === undefined || value === null) {
    return;
  } else if (typeof value === "object") {
    if (value instanceof Array) {
      for (let subValue of value) {
        serializeUrlParamsPart(subValue, path.withArraySegment(), partsAccumulator);
      }
    } else {
      for (let [key, subValue] of Object.entries(value)) {
        serializeUrlParamsPart(subValue, path.withSegment(key), partsAccumulator);
      }
    }
  } else {
    partsAccumulator.push(path.serializeWithValue(value));
  }
}

// The precise type is actually important to choose the right override of the HttpClient.
const paramLessOptions: { observe: 'body', responseType: 'json' } = {
  observe: 'body',
  responseType: 'json',
};

// The precise return type is actually important to choose the right override of the HttpClient.
function createOptions(data: object): { observe: 'body', responseType: 'json', params: HttpParams } {
  const params = serializeUrlParams(data);
  return {
    ...paramLessOptions,
    params,
  };
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  constructor(private readonly http: HttpClient) {}

  get<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.get<unknown>(constructUrl(relativeUrl), createOptions(data)).pipe(map(x => camelCaseifyFields<X>(x)));
  }

  post<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.post<unknown>(constructUrl(relativeUrl), serializeUrlParams(data), paramLessOptions).pipe(map(x => camelCaseifyFields<X>(x)));
  }

  put<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.put<unknown>(constructUrl(relativeUrl), serializeUrlParams(data), paramLessOptions).pipe(map(x => camelCaseifyFields<X>(x)));
  }

  patch<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.patch<unknown>(constructUrl(relativeUrl), serializeUrlParams(data), paramLessOptions).pipe(map(x => camelCaseifyFields<X>(x)));
  }

  delete<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.delete<unknown>(constructUrl(relativeUrl), createOptions(data)).pipe(map(x => camelCaseifyFields<X>(x)));
  }

  getBlob(relativeUrl: string): Observable<Blob> {
    return this.http.get(constructUrl(relativeUrl), {
      responseType: 'blob',
    });

  }
}
