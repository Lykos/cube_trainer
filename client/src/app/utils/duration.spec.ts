import { seconds, minutes, hours, days } from './duration';

fdescribe('Duration', () => {
  it('should support toString', () => {
    expect(seconds(3).toString()).toEqual('3');
    expect(seconds(3.1).toString()).toEqual('3.1');
    expect(seconds(3.1).plus(minutes(2)).toString()).toEqual('2:03.1');
    expect(seconds(3.1).plus(hours(2)).toString()).toEqual('2:00:03.1');
    expect(seconds(3.1).plus(days(2)).toString()).toEqual('2:00:00:03.1');
    expect(seconds(3.1).plus(days(2)).toString()).toEqual('2:00:00:03.1');
    expect(seconds(3.1).plus(minutes(2)).plus(hours(1)).plus(days(105)).toString()).toEqual('105:01:02:03.1');
  });
});
