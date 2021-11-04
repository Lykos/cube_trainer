// Data for a new user about to be created.
// Note that this has different data than an existing user.
// E.g., it has no id, but password and passwordConfirmation.
export interface NewUser {
  readonly name: string;
  readonly email: string;
  readonly password: string;
  readonly passwordConfirmation: string;
  readonly admin?: boolean;
}
