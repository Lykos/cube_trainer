export class Queue<X> {
  private readonly data: X[] = [];
  private popIndex = 0;
  private length_ = 0;

  constructor(readonly capacity: number) {}
  
  get length() {
    return this.length_;
  }

  get pushIndex() {
    return (this.popIndex + this.length_) % this.capacity;
  }

  get values() {
    const result: X[] = [];
    for (let i = 0; i < this.length_; ++i) {
      result.push(this.data[(this.popIndex + i) % this.capacity]);
    }
    return result;
  }

  push(x: X) {
    if (this.data.length < this.capacity) {
      this.data.push(x);
    } else {
      this.data[this.pushIndex] = x;
    }
    this.length_ = Math.min(this.length_ + 1, this.capacity);
  }

  front(): X {
    return this.data[this.popIndex];
  }

  pop(): X {
    if (this.length_ === 0) {
      throw new Error("Pop isn't allowed for an empty queue.");
    }
    const result = this.data[this.popIndex];
    --this.length_;
    this.popIndex = (this.popIndex + 1) % this.capacity;
    return result;
  }
}
