import { Observable, ReplaySubject, forkJoin } from 'rxjs';
import { flatMap, take } from 'rxjs/operators';
import { Queue } from './queue';

export class QueueCache<X> {
  readonly queue: Queue<ReplaySubject<X>>;

  constructor(capacity: number,
	      private readonly fetch: (xs: X[]) => Observable<X>) {
    this.queue = new Queue<ReplaySubject<X>>(capacity);
    for (let i = 0; i < capacity; ++i) {
      this.queue.push(this.createNextSubject());
    }
  }

  createNextSubject() {
    const subject = new ReplaySubject<X>(1);
    if (this.queue.values.length === 0) {
      this.fetch([]).subscribe(subject);
      return subject;
    }
    forkJoin(...this.queue.values.map(s => s.asObservable())).pipe(
      flatMap(xs => this.fetch(xs)),
      take(1),
    ).subscribe(subject);
    return subject;
  }

  get capacity() {
    return this.queue.capacity;
  }

  next(): Observable<X> {
    const subject = this.createNextSubject();
    const result = this.queue.pop().asObservable();
    this.queue.push(subject);
    return result;
  }
}
