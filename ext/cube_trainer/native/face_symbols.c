#include "face_symbols.h"

#include <stdlib.h>
#include "utils.h"

ID face_ids[cube_faces];

face_index_t face_index(const VALUE face_symbol) {
  Check_Type(face_symbol, T_SYMBOL);
  const ID face_id = SYM2ID(face_symbol);
  for (size_t i = 0; i < cube_faces; ++i) {
    if (face_ids[i] == face_id) {
      return i;
    }
  }
  rb_raise(rb_eArgError, "Invalid face symbol %+"PRIsVALUE"", face_symbol);
}

// TODO This is very unelegant.
const face_index_t U_neighbors[neighbor_faces] = {F, L, B, R};
const face_index_t F_neighbors[neighbor_faces] = {U, R, D, L};
const face_index_t R_neighbors[neighbor_faces] = {U, B, D, F};

face_index_t neighbor_face_index(const face_index_t face_index, const size_t index) {
  const size_t adjusted_index = face_index == axis_index(face_index) ? index : 3 - index;
  const size_t cropped_index = ((adjusted_index % 4) + 4) % 4;
  switch (axis_index(face_index)) {
  case U: return U_neighbors[cropped_index];
  case F: return F_neighbors[cropped_index];
  case R: return R_neighbors[cropped_index];
  default:
    // Crash
    break;
  }
}

VALUE face_symbol(const face_index_t face_index) {
  return ID2SYM(face_ids[face_index]);
}

face_index_t axis_index(const face_index_t face_index) {
  return MIN(face_index, opposite_face_index(face_index));
}

face_index_t opposite_face_index(const face_index_t face_index) {
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
