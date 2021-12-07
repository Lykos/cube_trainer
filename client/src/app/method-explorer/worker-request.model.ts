export interface WorkerRequest<X> {
  readonly data: X;
  readonly id: number;
}
