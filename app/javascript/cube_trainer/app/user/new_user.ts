// Data for a new user about to be created.
// Note that this has different data than an existing user.
// E.g., it has no id, but password and passwordConfirmation.
interface NewUser {
  readonly name: string;
  readonly password: string;
  readonly passwordConfirmation: string;
  readonly admin: string;
}
