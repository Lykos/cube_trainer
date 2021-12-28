import { RailsService } from './rails.service';
import { environment } from '@environment';
import { TestBed } from '@angular/core/testing';
// @ts-ignore
import Rails from '@rails/ujs';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { HttpVerb } from './http-verb';

// TODO: Figure out how to make these HTTP tests run.
xdescribe('RailsService', () => {
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

  it('should make an ajax call for an empty object', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('');
    req.flush('successful');

    railsService.ajax(HttpVerb.Get, '/stuff', {}).subscribe((result) => { expect(result).toEqual('successful'); })
  });

  it('should make an ajax call with snake caseified URL parameters', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_int=23&some_string=abc');
    req.flush('successful');
    const params = {
      SomeInt: 23,
      someString: 'abc',
    };

    railsService.ajax(HttpVerb.Get, '/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })
  });

  it('should make an ajax call with snake escaped URL parameters', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('needs_escape=a%20b%20c');
    req.flush('successful');
    const params = {
      needsEscape: 'a b c',
    };

    railsService.ajax(HttpVerb.Get, '/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })
  });

  it('should make an ajax call with inner object URL parameters', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_object%5Bsome_inner_object%5D%5Ba%5D=2&some_object%5Bb%5D=3');
    req.flush('successful');
    const params = {
      someObject: {
	someInnerObject: {
	  a: 2,
	},
	b: 3,
      },
    };

    railsService.ajax(HttpVerb.Get, '/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })
  });

  it('should make an ajax call with array URL parameters', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_array%5B%5D=1&some_array%5B%5D=2&some_array%5B%5D=3');
    req.flush('successful');
    const params = {
      someArray: [1, 2, 3],
    };

    railsService.ajax(HttpVerb.Get, '/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })
  });

  it('should make an ajax call with object array URL parameters', () => {
    const req = httpMock.expectOne('/stuff');
    expect(req.request.method).toEqual(HttpVerb.Get);
    expect(req.request.url).toEqual(`${environment.apiPrefix}/stuff`);
    expect(req.request.responseType).toEqual('json');
    expect(req.request.params.toString()).toEqual('some_object_array%5B%5D%5Bc%5D=12');
    req.flush('successful');
    const params = {
      someObjectArray: [{c: 12}],
    };

    railsService.ajax(HttpVerb.Get, '/stuff', params).subscribe((result) => { expect(result).toEqual('successful'); })
  });
});
