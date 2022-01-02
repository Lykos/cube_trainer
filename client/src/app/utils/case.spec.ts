import { camelCaseToSnakeCase, snakeCaseToCamelCase, camelCaseifyFields } from './case';

describe('RailsService', () => {
  it('snake caseifies a simple example', () => {
    expect(camelCaseToSnakeCase('ButterEater')).toEqual('butter_eater');
  });

  it('snake caseifies an example with numbers', () => {
    expect(camelCaseToSnakeCase('Butter8Eater9')).toEqual('butter8_eater9');
  });

  it('snake caseifies an example with consecutive capital letters', () => {
    expect(camelCaseToSnakeCase('ABCWeapon')).toEqual('a_b_c_weapon');
  });

  it('camel caseifies a simple example', () => {
    expect(snakeCaseToCamelCase('butter_eater')).toEqual('butterEater');
  });

  it('camel caseifies an example with numbers', () => {
    expect(snakeCaseToCamelCase('butter_8eater')).toEqual('butter8eater');
  });

  it('camel caseifies fields of an object', () => {
    expect(camelCaseifyFields<any>({ some_number: 2, some_string: 'abc' })).toEqual({ someNumber: 2, someString: 'abc' });
  });

  it('camel caseifies fields of a nested object', () => {
    expect(camelCaseifyFields<any>({ some_object: { some_nested_object: { some_field: 2 }, another_field: 3 } })).toEqual({ someObject: { someNestedObject: { someField: 2 }, anotherField: 3 } });
  });

  it('camel caseifies fields of an object', () => {
    expect(camelCaseifyFields<any>({ some_array: [{ some_field: 12}] })).toEqual({ someArray: [{ someField: 12 }] });
  });
});
