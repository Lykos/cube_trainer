import { Observable, ReplaySubject, zip } from 'rxjs';
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
    const xs$ = zip(...this.queue.values.map(s => s.asObservable()));
    xs$.subscribe(xs => this.fetch(xs).subscribe(subject));
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
