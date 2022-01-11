import { RailsService } from './rails.service';
import { environment } from '@environment';
import { TestBed } from '@angular/core/testing';
// @ts-ignore
import Rails from '@core/ujs';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { HttpVerb } from './http-verb';

describe('RailsService', () => {
  let httpMock: HttpTestingController;
  let railsService: RailsService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [RailsService],
    });

    // Inject the http service and test controller for each test
    httpMock = TestBed.inject(HttpTestingController);
    railsService = TestBed.inject(RailsService);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should make an get call for an empty object', () => {
    railsService.get('/stuff', {}).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('');
    req.flush('successful');
  });

  it('should make an get call with snake caseified URL parameters', () => {
    const params = {
      SomeInt: 23,
      someString: 'abc',
    };
    railsService.get('/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff?some_int=23&some_string=abc`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_int=23&some_string=abc');
    req.flush('successful');
  });

  it('should make an get call with snake escaped URL parameters', () => {
    const params = {
      needsEscape: 'a b c',
    };
    railsService.get('/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff?needs_escape=a%20b%20c`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('needs_escape=a%20b%20c');
    req.flush('successful');
  });

  it('should make an get call with nested object URL parameters', () => {
    const params = {
      someObject: {
	someInnerObject: {
	  a: 2,
	},
	b: 3,
      },
    };
    railsService.get('/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff?some_object%5Bsome_inner_object%5D%5Ba%5D=2&some_object%5Bb%5D=3`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_object%5Bsome_inner_object%5D%5Ba%5D=2&some_object%5Bb%5D=3');
    req.flush('successful');
  });

  it('should make an get call with array URL parameters', () => {
    const params = {
      someArray: [1, 2, 3],
    };
    railsService.get('/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff?some_array%5B%5D=1&some_array%5B%5D=2&some_array%5B%5D=3`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_array%5B%5D=1&some_array%5B%5D=2&some_array%5B%5D=3');
    req.flush('successful');
  });

  it('should make an get call with object array URL parameters', () => {
    const params = {
      someObjectArray: [{c: 12}],
    };
    railsService.get('/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff?some_object_array%5B%5D%5Bc%5D=12`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_object_array%5B%5D%5Bc%5D=12');
    req.flush('successful');
  });


  it('should raise on nested arrays', () => {
    const params = {array: [[2]]};
    expect(() => { railsService.get('/stuff', params); }).toThrow();
  });

  it('should return objects with camel caseified fields', () => {
    railsService.get('/stuff', {}).subscribe((result) => { expect(result).toEqual({ someNumber: 2, someString: 'abc' }); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('');
    req.flush({ some_number: 2, some_string: 'abc' });
  });

  it('should return objects with camel caseified nested fields', () => {
    railsService.get('/stuff', {}).subscribe((result) => { expect(result).toEqual({ someObject: { someNestedObject: { someField: 2 }, anotherField: 3 } }); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('');
    req.flush({ some_object: { some_nested_object: { some_field: 2 }, another_field: 3 } });
  });

  it('should return objects with camel caseified object array fields', () => {
    railsService.get('/stuff', {}).subscribe((result) => { expect(result).toEqual({ someArray: [{ someField: 12 }] }); })

    const req = httpMock.expectOne(`${environment.apiPrefix}/stuff`);
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('');
    req.flush({ some_array: [{ some_field: 12}] });
  });
});
