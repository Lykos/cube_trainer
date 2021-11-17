import { RailsService } from './rails.service';
import { environment } from './../../environments/environment';
// @ts-ignore
import Rails from '@rails/ujs';
import { HttpClient, HttpClientTestingModule } from '@angular/common/http';
import { HttpVerb } from './http-verb';

describe('RailsService', () => {
  let httpClient: HttpClient;
  let httpTestingController: HttpTestingController;

  beforEach(() => {
    TestBed.configureTestingModule({
      imports: [ HttpClientTestingModule ]
    });

    // Inject the http service and test controller for each test
    httpClient = TestBed.inject(HttpClient);
    httpTestingController = TestBed.inject(HttpTestingController);
  });
  // TODO Use angular tests.
  it('should make an ajax call for an empty object', async () => {
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('');
      param.success('successful');
    });

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', {}).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with snake caseified URL parameters', async () => {
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_int=23&some_string=abc');
      param.success('successful');
    });
    const params = {
      SomeInt: 23,
      someString: 'abc',
    };

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with snake escaped URL parameters', async () => {
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('needs_escape=a%20b%20c');
      param.success('successful');
    });
    const params = {
      needsEscape: 'a b c',
    };

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with inner object URL parameters', async () => {
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_object%5Bsome_inner_object%5D%5Ba%5D=2&some_object%5Bb%5D=3');
      param.success('successful');
    });
    const params = {
      someObject: {
	someInnerObject: {
	  a: 2,
	},
	b: 3,
      },
    };

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with array URL parameters', async () => {
    const httpClient = {ajax(param: any) {}};
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_array%5B%5D=1&some_array%5B%5D=2&some_array%5B%5D=3');
      param.success('successful');
    });
    const params = {
      someArray: [1, 2, 3],
    };

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with object array URL parameters', async () => {
    spyOn(httpClient, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_object_array%5B%5D%5Bc%5D=12');
      param.success('successful');
    });
    const params = {
      someObjectArray: [{c: 12}],
    };

    const result = await new RailsService(httpClient).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(httpClient.ajax).toHaveBeenCalled();
  });
});
