export enum ExecutionOrder {
  CE, EC
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
}
