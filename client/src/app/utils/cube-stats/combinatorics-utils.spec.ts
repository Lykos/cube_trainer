import { ncr, factorial } from './combinatorics-utils';

describe('combinatorics-utils', () => {
  it('should compute 0! correctly', () => {
    expect(factorial(0)).toEqual(1);
  });

  it('should compute 1! correctly', () => {
    expect(factorial(1)).toEqual(1);
  });

  it('should compute 2! correctly', () => {
    expect(factorial(2)).toEqual(2);
  });

  it('should compute 6! correctly', () => {
    expect(factorial(6)).toEqual(720);
  });
  
  it('should compute ncr(1, 0) correctly', () => {
    expect(ncr(1, 0)).toEqual(1);
  });
  
  it('should compute ncr(1, 1) correctly', () => {
    expect(ncr(1, 1)).toEqual(1);
  });
  
  it('should compute ncr(6, 0) correctly', () => {
    expect(ncr(6, 0)).toEqual(1);
  });
  
  it('should compute ncr(6, 1) correctly', () => {
    expect(ncr(6, 1)).toEqual(6);
  });
  
  it('should compute ncr(6, 2) correctly', () => {
    expect(ncr(6, 2)).toEqual(15);
  });
  
  it('should compute ncr(6, 3) correctly', () => {
    expect(ncr(6, 3)).toEqual(20);
  });
  
  it('should compute ncr(6, 4) correctly', () => {
    expect(ncr(6, 4)).toEqual(15);
  });
  
  it('should compute ncr(6, 5) correctly', () => {
    expect(ncr(6, 5)).toEqual(6);
  });
  
  it('should compute ncr(6, 6) correctly', () => {
    expect(ncr(6, 6)).toEqual(1);
  });
});
