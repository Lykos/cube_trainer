#include "skewb_algorithm.h"

#include "face_symbols.h"
#include "skewb_coordinate.h"
#include "skewb_state.h"
#include "utils.h"

static ID move_id;
static ID rotation_id;
static VALUE SkewbAlgorithmClass = Qnil;

typedef enum {
  MOVE,
  ROTATION,
} SkewbMoveType;

typedef union {
  Corner corner;
  face_index_t face_index;
} SkewbAxis;

typedef struct {
  SkewbMoveType type;
  SkewbAxis axis;
  direction_t direction;
} SkewbMove;

typedef struct {
  size_t size;
  // We need this because we can't use the usual checking for 0/NULL because and empty algorithm is valid.
  bool initialized;
  SkewbMove* moves;
} SkewbAlgorithmData;

static void SkewbAlgorithmData_free(void* const ptr) {
  const SkewbAlgorithmData* const data = ptr;
  free(data->moves);
  free(ptr);
}

static size_t SkewbAlgorithmData_size(const void* const ptr) {
  const SkewbAlgorithmData* const data = ptr;
  return sizeof(SkewbAlgorithmData) + data->size * sizeof(SkewbMove);
}

const rb_data_type_t SkewbAlgorithmData_type = {
  "CubeTrainer::Native::SkewbAlgorithmData",
  {NULL, SkewbAlgorithmData_free, SkewbAlgorithmData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static void check_moves(const SkewbAlgorithmData* const data, const char* const name) {
  for (size_t i = 0; i < data->size; ++i) {
    const SkewbMoveType type = data->moves[i].type;
    if (type != MOVE && type != ROTATION) {
      rb_raise(rb_eRuntimeError, "invalid move type %d in %s", type, name);
    }
  }
}

static SkewbMove* malloc_moves(const size_t n) {
  SkewbMove* const moves = malloc(n * sizeof(SkewbMove));
  if (moves == NULL) {
    rb_raise(rb_eNoMemError, "Allocating skewb algorithm failed.");
  }
  return moves;
}

static VALUE SkewbAlgorithm_alloc(const VALUE klass) {
  SkewbAlgorithmData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbAlgorithmData, &SkewbAlgorithmData_type, data);
  data->size = 0;
  data->initialized = FALSE;
  data->moves = NULL;
  return object;
}

#define GetSkewbAlgorithmData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), SkewbAlgorithmData, &SkewbAlgorithmData_type, (data)); \
  } while (0)

#define GetInitializedSkewbAlgorithmData(obj, data) \
  do { \
    GetSkewbAlgorithmData((obj), (data)); \
    if (!data->initialized) { \
      rb_raise(rb_eRuntimeError, "Skewb algorithm isn't initialized."); \
    } \
  } while(0)

static SkewbMoveType extract_move_type(const VALUE move_symbol) {
  Check_Type(move_symbol, T_SYMBOL);
  const ID move_symbol_id = SYM2ID(move_symbol);
  if (move_symbol_id == move_id) {
    return MOVE;
  } else if (move_symbol_id == rotation_id) {
    return ROTATION;
  } else {
    rb_raise(rb_eArgError, "Got invalid move symbol.");
  }
}

static SkewbAxis extract_axis(const SkewbMoveType type, const VALUE axis) {
  SkewbAxis result;
  switch (type) {
  case MOVE:
    result.corner = extract_corner(axis);
    return result;
  case ROTATION:
    result.face_index = face_index(axis);
    return result;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in extract_axis", type);
  }
}

static VALUE SkewbAlgorithm_initialize(const VALUE self, const VALUE moves) {
  Check_Type(moves, T_ARRAY);
  SkewbAlgorithmData* data;
  GetSkewbAlgorithmData(self, data);
  data->size = RARRAY_LEN(moves);
  data->initialized = TRUE;
  data->moves = malloc_moves(data->size);
  for (size_t i = 0; i < RARRAY_LEN(moves); ++i) {
    const VALUE move = rb_ary_entry(moves, i);
    if (RARRAY_LEN(move) != 3) {
      rb_raise(rb_eArgError, "Moves must have 3 elements. Got %ld.", RARRAY_LEN(moves));
    }
    const SkewbMoveType type = extract_move_type(rb_ary_entry(move, 0));
    data->moves[i].type = type;
    data->moves[i].axis = extract_axis(type, rb_ary_entry(move, 1));
    data->moves[i].direction = NUM2INT(rb_ary_entry(move, 2));
  }
  return self;
}

static void apply_move_to(const SkewbMove move, SkewbStateData* const skewb_state) {
  switch (move.type) {
  case MOVE:
    rotate_corner_for_skewb_state(move.axis.corner, move.direction, skewb_state);
    break;
  case ROTATION:
    rotate_skewb_state(move.axis.face_index, move.direction, skewb_state);
    break;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in apply_move_to", move.type);
  }
}

static VALUE SkewbAlgorithm_apply_to(const VALUE self, const VALUE skewb_state) {
  SkewbStateData* skewb_state_data;
  GetSkewbStateData(skewb_state, skewb_state_data);
  const SkewbAlgorithmData* data;
  GetInitializedSkewbAlgorithmData(self, data);
  for (size_t i = 0; i < data->size; ++i) {
    apply_move_to(data->moves[i], skewb_state_data);
  }
  return Qnil;
}

// Takes either face_index or the opposite, depending which one is present on corner.
static face_index_t axis_face_on_corner(const Corner corner, const face_index_t face_index) {
  for (size_t i = 0; i < 3; ++i) {
    if (same_axis(corner.face_indices[i], face_index)) {
      return corner.face_indices[i];
    }
  }
  rb_raise(rb_eRuntimeError, "invalid state in axis_face_on_corner");
}

bool corners_eq(Corner left, Corner right) {
  return left.face_indices[0] == right.face_indices[0] &&
    (left.face_indices[1] == right.face_indices[1] && left.face_indices[2] == right.face_indices[2] ||
     left.face_indices[1] == right.face_indices[2] && left.face_indices[2] == right.face_indices[1]);
}

size_t equivalent_corner_index(const FaceCorners corners, const Corner corner) {  
  for (size_t i = 0; i < 4; ++i) {
    for (int j = 0; j < 3; ++j) {
      if (corners_eq(rotated_corner(corners.corners[i], j), corner)) {
        return i;
      }
    }
  }
  rb_raise(rb_eRuntimeError, "invalid state in equivalent_corner_index");
}

static SkewbMove rotate_move_by(const SkewbMove move, const face_index_t rotation_face_index, const direction_t rotation_direction) {
  SkewbMove result = move;
  switch (move.type) {
  case MOVE: {
    const face_index_t nice_rotation_face_index = axis_face_on_corner(move.axis.corner, rotation_face_index);
    const face_index_t nice_rotation_direction = rotation_face_index == nice_rotation_face_index ? rotation_direction : invert_cube_direction(rotation_direction);
    FaceCorners corners = get_face_corners(nice_rotation_face_index);
    const size_t corner_index = equivalent_corner_index(corners, move.axis.corner);
    result.axis.corner = corners.corners[(corner_index + nice_rotation_direction) % 4];
    break;
  }
  case ROTATION: {
    if (!same_axis(move.axis.face_index, rotation_face_index)) {
      const size_t index = neighbor_index(rotation_face_index, move.axis.face_index);
      result.axis.face_index = neighbor_face_index(rotation_face_index, index + rotation_direction);
    }
    break;
  }
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in rotate_move_by", move.type);
  }
  return result;
}

static VALUE SkewbAlgorithm_rotate_by(const VALUE self, const VALUE rotation_face_symbol, const VALUE direction) {
  const face_index_t rotation_face_index = face_index(rotation_face_symbol);
  const direction_t rotation_direction = NUM2INT(direction);
  const SkewbAlgorithmData* data;
  GetInitializedSkewbAlgorithmData(self, data);
  SkewbAlgorithmData* rotated_data;
  const VALUE rotated = TypedData_Make_Struct(SkewbAlgorithmClass, SkewbAlgorithmData, &SkewbAlgorithmData_type, rotated_data);
  rotated_data->size = data->size;
  rotated_data->initialized = TRUE;
  rotated_data->moves = malloc_moves(rotated_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    rotated_data->moves[i] = rotate_move_by(data->moves[i], rotation_face_index, rotation_direction);
  }
  return rotated;
}

static SkewbMove mirror_move(const SkewbMove move, const face_index_t normal_face_index) {
  SkewbMove result = move;
  switch (move.type) {
  case MOVE: {
    for (size_t i = 0; i < 3; ++i) {
      const face_index_t current_face_index = move.axis.corner.face_indices[i];
      if (same_axis(current_face_index, normal_face_index)) {
        // We need to make one face into the opposite and then swap to to fix the chirality.
        result.axis.corner.face_indices[(i + 1) % 3] = opposite_face_index(current_face_index);
        result.axis.corner.face_indices[i] = move.axis.corner.face_indices[(i + 1) % 3];
        break;
      }
    }
    result.direction = invert_skewb_direction(result.direction);
    break;
  }
  case ROTATION:
    break;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in mirror_move", move.type);
  }
  return result;
}

static VALUE SkewbAlgorithm_mirror(const VALUE self, const VALUE normal_face_symbol) {
  const face_index_t normal_face_index = face_index(normal_face_symbol);
  const SkewbAlgorithmData* data;
  GetInitializedSkewbAlgorithmData(self, data);
  SkewbAlgorithmData* mirrored_data;
  const VALUE mirrored = TypedData_Make_Struct(SkewbAlgorithmClass, SkewbAlgorithmData, &SkewbAlgorithmData_type, mirrored_data);
  mirrored_data->size = data->size;
  mirrored_data->initialized = TRUE;
  mirrored_data->moves = malloc_moves(mirrored_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    mirrored_data->moves[i] = mirror_move(data->moves[i], normal_face_index);
  }
  return mirrored;
}

static SkewbMove invert_move(const SkewbMove move) {
  SkewbMove result = move;
  switch (move.type) {
  case MOVE:
    result.direction = invert_skewb_direction(result.direction);
    break;
  case ROTATION:
    result.direction = invert_cube_direction(result.direction);
    break;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in invert_move", move.type);
  }
  return result;
}

static VALUE SkewbAlgorithm_inverse(const VALUE self) {
  const SkewbAlgorithmData* data;
  GetInitializedSkewbAlgorithmData(self, data);
  SkewbAlgorithmData* inverted_data;
  const VALUE inverted = TypedData_Make_Struct(SkewbAlgorithmClass, SkewbAlgorithmData, &SkewbAlgorithmData_type, inverted_data);
  inverted_data->size = data->size;
  inverted_data->initialized = TRUE;
  inverted_data->moves = malloc_moves(inverted_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    inverted_data->moves[i] = invert_move(data->moves[data->size - 1 - i]);
  }
  return inverted;
}

static VALUE SkewbAlgorithm_plus(const VALUE self, const VALUE other) {
  const SkewbAlgorithmData* self_data;
  GetInitializedSkewbAlgorithmData(self, self_data);
  const SkewbAlgorithmData* other_data;
  GetInitializedSkewbAlgorithmData(other, other_data);
  SkewbAlgorithmData* sum_data;
  const VALUE sum = TypedData_Make_Struct(SkewbAlgorithmClass, SkewbAlgorithmData, &SkewbAlgorithmData_type, sum_data);
  sum_data->size = self_data->size + other_data->size;
  sum_data->initialized = TRUE;
  sum_data->moves = malloc_moves(sum_data->size);
  for (size_t i = 0; i < self_data->size; ++i) {
    sum_data->moves[i] = self_data->moves[i];
  }
  for (size_t i = 0; i < other_data->size; ++i) {
    sum_data->moves[self_data->size + i] = other_data->moves[i];
  }
  return sum;
}

void init_skewb_algorithm_class_under(const VALUE module) {
  move_id = rb_intern("move");
  rotation_id = rb_intern("rotation");
  SkewbAlgorithmClass = rb_define_class_under(module, "SkewbAlgorithm", rb_cObject);
  rb_define_alloc_func(SkewbAlgorithmClass, SkewbAlgorithm_alloc);
  rb_define_method(SkewbAlgorithmClass, "initialize", SkewbAlgorithm_initialize, 1);
  rb_define_method(SkewbAlgorithmClass, "apply_to", SkewbAlgorithm_apply_to, 1);
  rb_define_method(SkewbAlgorithmClass, "rotate_by", SkewbAlgorithm_rotate_by, 2);
  rb_define_method(SkewbAlgorithmClass, "mirror", SkewbAlgorithm_mirror, 1);
  rb_define_method(SkewbAlgorithmClass, "inverse", SkewbAlgorithm_inverse, 0);
  rb_define_method(SkewbAlgorithmClass, "+", SkewbAlgorithm_plus, 1);
}
