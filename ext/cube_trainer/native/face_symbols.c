#include "face_symbols.h"

#include <stdlib.h>
#include "utils.h"

ID face_ids[cube_faces];

FACE_INDEX face_index(const VALUE face_symbol) {
  Check_Type(face_symbol, T_SYMBOL);
  const ID face_id = SYM2ID(face_symbol);
  for (int i = 0; i < cube_faces; ++i) {
    if (face_ids[i] == face_id) {
      return i;
    }
  }
  rb_raise(rb_eArgError, "Invalid face symbol %+"PRIsVALUE"", face_symbol);
}

// TODO This is very unelegant.
const FACE_INDEX U_neighbors[neighbor_faces] = {F, L, B, R};
const FACE_INDEX F_neighbors[neighbor_faces] = {U, R, D, L};
const FACE_INDEX R_neighbors[neighbor_faces] = {U, B, D, F};

FACE_INDEX neighbor_face_index(const FACE_INDEX face_index, const int index) {
  const int canonical_index = face_index == axis_index(face_index) ? index : 3 - index;
  switch (axis_index(face_index)) {
  case U: return U_neighbors[canonical_index];
  case F: return F_neighbors[canonical_index];
  case R: return R_neighbors[canonical_index];
  default:
    // Crash
    break;
  }
}

VALUE face_symbol(const FACE_INDEX face_index) {
  return ID2SYM(face_ids[face_index]);
}

FACE_INDEX axis_index(const FACE_INDEX face_index) {
  return MIN(face_index, opposite_face_index(face_index));
}

FACE_INDEX opposite_face_index(const FACE_INDEX face_index) {
  return cube_faces - 1 - face_index;
}

void init_face_symbols() {
  face_ids[U] = rb_intern("U");
  face_ids[F] = rb_intern("F");
  face_ids[R] = rb_intern("R");
  face_ids[L] = rb_intern("L");
  face_ids[B] = rb_intern("B");
  face_ids[D] = rb_intern("D");
}
