import { some, none, mapOptional, forceValue, hasValue, checkNone } from '../../app/javascript/cube_trainer/app/utils/optional';
import { expect } from 'chai';

describe('Optional', () => {
  it('should support mapOptional', () => {
    expect(mapOptional(some(2), x => x + 1)).to.eql(some(3));
    expect(mapOptional(none, (x: number) => x + 1)).to.eql(none);
  });

  it('should support forceValue', () => {
    expect(forceValue(some(2))).to.equal(2);
    expect(() => forceValue(none)).to.throw();
  });

  it('should support hasValue', () => {
    expect(hasValue(some(2))).to.be.true;
    expect(hasValue(none)).to.be.false;
  });

  it('should support checkNone', () => {
    expect(() => checkNone(some(2))).to.throw();
    expect(() => checkNone(none)).not.to.throw();
  });
});
