#include "face_symbols.h"

#include <stdlib.h>
#include "utils.h"

// Compiler doesn't like a constant here.
ID face_ids[6];

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
  face_ids[0] = rb_intern("U");
  face_ids[1] = rb_intern("F");
  face_ids[2] = rb_intern("R");
  face_ids[3] = rb_intern("L");
  face_ids[4] = rb_intern("B");
  face_ids[5] = rb_intern("D");
}
