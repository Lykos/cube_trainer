import { OrError } from '@shared/or-error.type';

export interface WorkerResponse<X> {
  readonly dataOrError: OrError<X>;
  readonly id: number;
}
