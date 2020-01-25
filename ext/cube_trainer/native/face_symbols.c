const VALUE[cube_faces] face_symbols;

FACE_INDEX face_index(const VALUE symbol) {
  Check_Type(symbol, T_SYMBOL);
  for (FACE_INDEX i = 0; i < cube_faces; ++i) {
    if (rb_funcallv_public(symbol, rb_intern("=="), 1, &face_symbols[i]) == Qtrue) {
      return i;
    }
  }
  rb_raise(rb_eRuntimeError, "Invalid face symbol.");
}

VALUE face_symbol(const FACE_INDEX face_index) {
  return face_symbols[face_index];
}

FACE_INDEX axis_index(const FACE_INDEX face_index) {
  return face_index % 3;
}

FACE_INDEX opposite_face_index(const FACE_INDEX face_index) {
  switch (face_index) {
  case U: return D;
  case F: return B;
  case R: return L;
  case L: return R;
  case B: return F;
  case D: return U;
  default:
    // Crash
  }
}

void init_face_symbols() {
  const rb_encoding* const ascii = rb_enc_find("ASCII");
  face_symbols[U] = rb_check_symbol_c_str("U", 1, ascii);
  face_symbols[F] = rb_check_symbol_c_str("F", 1, ascii);
  face_symbols[R] = rb_check_symbol_c_str("R", 1, ascii);
  face_symbols[L] = rb_check_symbol_c_str("L", 1, ascii);
  face_symbols[B] = rb_check_symbol_c_str("B", 1, ascii);
  face_symbols[D] = rb_check_symbol_c_str("D", 1, ascii);
}
