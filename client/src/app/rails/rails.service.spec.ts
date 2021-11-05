import { RailsService } from './rails.service';
import { environment } from './../../environments/environment';
// @ts-ignore
import Rails from '@rails/ujs';
import { HttpVerb } from './http-verb';

describe('RailsService', () => {
  it('should make an ajax call for an empty object', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('');
      param.success('successful');
    });

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', {}).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with snake caseified URL parameters', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
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

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with snake escaped URL parameters', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('needs_escape=a%20b%20c');
      param.success('successful');
    });
    const params = {
      needsEscape: 'a b c',
    };

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with inner object URL parameters', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
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

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with array URL parameters', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_array%5B%5D=1&some_array%5B%5D=2&some_array%5B%5D=3');
      param.success('successful');
    });
    const params = {
      someArray: [1, 2, 3],
    };

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });

  it('should make an ajax call with object array URL parameters', async () => {
    const rails = {ajax(param: any) {}};
    spyOn(rails, 'ajax').and.callFake(function(param: any) {
      expect(param?.type).toEqual(HttpVerb.Get);
      expect(param?.url).toEqual(`${environment.apiPrefix}/stuff`);
      expect(param?.dataType).toEqual('json');
      expect(param?.data).toEqual('some_object_array%5B%5D%5Bc%5D=12');
      param.success('successful');
    });
    const params = {
      someObjectArray: [{c: 12}],
    };

    const result = await new RailsService(rails).ajax(HttpVerb.Get, '/stuff', params).toPromise();

    expect(result).toEqual('successful');
    expect(rails.ajax).toHaveBeenCalled();
  });
});
