import { camelCaseToSnakeCase, camelCaseifyFieldNames, snakeCaseifyFieldNames } from '@utils/case';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
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
    if (this.path.includes('')) {
      throw Error('Nested arrays do not work in URL params');
    }
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
    if (Array.isArray(value)) {
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
const commonOptions = {
  observe: 'body' as const,
  responseType: 'json' as const,
};

const jsonContentOptions = {
  ...commonOptions,
  headers: new HttpHeaders().set('Content-Type', 'application/json'),
}

// The precise return type is actually important to choose the right override of the HttpClient.
function createOptions(data: object) {
  const params = serializeUrlParams(data);
  return {
    ...commonOptions,
    params,
  };
}

@Injectable({
  providedIn: 'root',
})
export class RailsService {
  constructor(private readonly http: HttpClient) {}

  // Note that data cannot contain nested arrays.
  get<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.get<unknown>(constructUrl(relativeUrl), createOptions(data)).pipe(map(x => camelCaseifyFieldNames<X>(x)));
  }

  post<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.post<unknown>(constructUrl(relativeUrl), snakeCaseifyFieldNames(data), jsonContentOptions).pipe(map(x => camelCaseifyFieldNames<X>(x)));
  }

  put<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.put<unknown>(constructUrl(relativeUrl), snakeCaseifyFieldNames(data), jsonContentOptions).pipe(map(x => camelCaseifyFieldNames<X>(x)));
  }

  patch<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.patch<unknown>(constructUrl(relativeUrl), snakeCaseifyFieldNames(data), jsonContentOptions).pipe(map(x => camelCaseifyFieldNames<X>(x)));
  }

  delete<X>(relativeUrl: string, data: object): Observable<X> {
    return this.http.delete<unknown>(constructUrl(relativeUrl), createOptions(data)).pipe(map(x => camelCaseifyFieldNames<X>(x)));
  }

  getBlob(relativeUrl: string): Observable<Blob> {
    return this.http.get(constructUrl(relativeUrl), {
      responseType: 'blob',
    });

  }
}
