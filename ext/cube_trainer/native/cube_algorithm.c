#include "cube_algorithm.h"

#include "face_symbols.h"
#include "cube_coordinate.h"
#include "cube_state.h"
#include "utils.h"

static ID slice_id;
static ID face_id;
static VALUE CubeAlgorithmClass = Qnil;

typedef enum {
  SLICE,
  FACE,
} CubeMoveType;

typedef struct {
  CubeMoveType type;
  face_index_t axis_face_index;
  direction_t direction;
  size_t slice_index;
} CubeMove;

typedef struct {
  size_t size;
  size_t cube_size;
  CubeMove* moves;
} CubeAlgorithmData;

static void CubeAlgorithmData_free(void* const ptr) {
  const CubeAlgorithmData* const data = ptr;
  free(data->moves);
  free(ptr);
}

static size_t CubeAlgorithmData_size(const void* const ptr) {
  const CubeAlgorithmData* const data = ptr;
  return sizeof(CubeAlgorithmData) + data->size * sizeof(CubeMove);
}

const rb_data_type_t CubeAlgorithmData_type = {
  "CubeTrainer::Native::CubeAlgorithmData",
  {NULL, CubeAlgorithmData_free, CubeAlgorithmData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static void check_moves(const CubeAlgorithmData* const data, const char* const name) {
  for (size_t i = 0; i < data->size; ++i) {
    const CubeMoveType type = data->moves[i].type;
    if (type != SLICE && type != FACE) {
      rb_raise(rb_eRuntimeError, "invalid move type %d in %s", type, name);
    }
  }
}

static CubeMove* malloc_moves(const size_t n) {
  CubeMove* const moves = malloc(n * sizeof(CubeMove));
  if (moves == NULL) {
    rb_raise(rb_eNoMemError, "Allocating cube algorithm failed.");
  }
  return moves;
}

static VALUE CubeAlgorithm_alloc(const VALUE klass) {
  CubeAlgorithmData* data;
  const VALUE object = TypedData_Make_Struct(klass, CubeAlgorithmData, &CubeAlgorithmData_type, data);
  data->size = 0;
  data->cube_size = 0;
  data->moves = NULL;
  return object;
}

#define GetCubeAlgorithmData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), CubeAlgorithmData, &CubeAlgorithmData_type, (data)); \
  } while (0)

#define GetInitializedCubeAlgorithmData(obj, data) \
  do { \
    GetCubeAlgorithmData((obj), (data)); \
    if (data->cube_size == 0) { \
      rb_raise(rb_eRuntimeError, "Cube algorithm isn't initialized."); \
    } \
  } while(0)

static CubeMoveType extract_move_type(const VALUE move_symbol) {
  Check_Type(move_symbol, T_SYMBOL);
  const ID move_symbol_id = SYM2ID(move_symbol);
  if (move_symbol_id == slice_id) {
    return SLICE;
  } else if (move_symbol_id == face_id) {
    return FACE;
  } else {
    rb_raise(rb_eArgError, "Got invalid move symbol.");
  }
}

static size_t components_for_move_type(const CubeMoveType type) {
  switch (type) {
  case SLICE:
    return 4;
  case FACE:
    return 3;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in components_for_move_type", type);
  }
}

static VALUE CubeAlgorithm_initialize(const VALUE self, const VALUE cube_size, const VALUE moves) {
  Check_Type(moves, T_ARRAY);
  CubeAlgorithmData* data;
  GetCubeAlgorithmData(self, data);
  data->size = RARRAY_LEN(moves);
  data->cube_size = NUM2INT(cube_size);
  data->moves = malloc_moves(data->size);
  for (size_t i = 0; i < RARRAY_LEN(moves); ++i) {
    const VALUE move = rb_ary_entry(moves, i);
    if (RARRAY_LEN(move) < 1) {
      rb_raise(rb_eArgError, "Moves cannot be empty.");
    }
    const CubeMoveType type = extract_move_type(rb_ary_entry(move, 0));
    const size_t num_components = components_for_move_type(type);
    if (RARRAY_LEN(move) != num_components) {
      rb_raise(rb_eArgError, "Moves with the given type need to have %ld elements. Got %ld.", num_components, RARRAY_LEN(move));
    }
    data->moves[i].type = type;
    data->moves[i].axis_face_index = face_index(rb_ary_entry(move, 1));
    data->moves[i].direction = NUM2INT(rb_ary_entry(move, 2));
    if (type == SLICE) {
      const size_t slice_index = NUM2INT(rb_ary_entry(move, 3));
      if (slice_index >= data->cube_size) {
        rb_raise(rb_eArgError, "Invalid slice index %ld for cube size %ld.", slice_index, data->cube_size);
      }
      data->moves[i].slice_index = slice_index;
    }
  }
  return self;
}

static void apply_move_to(const CubeMove move, const CubeStateData* const cube_state) {
  switch (move.type) {
  case SLICE:
    rotate_slice_for_cube(move.axis_face_index, move.slice_index, move.direction, cube_state);
    break;
  case FACE:
    rotate_face_for_cube(move.axis_face_index, move.direction, cube_state);
    break;
  default:
    rb_raise(rb_eRuntimeError, "invalid move type %d in apply_move_to", move.type);
  }
}

static VALUE CubeAlgorithm_apply_to(const VALUE self, const VALUE cube_state) {
  const CubeStateData* cube_state_data;
  GetInitializedCubeStateData(cube_state, cube_state_data);
  const CubeAlgorithmData* data;
  GetInitializedCubeAlgorithmData(self, data);
  for (size_t i = 0; i < data->size; ++i) {
    apply_move_to(data->moves[i], cube_state_data);
  }
  return Qnil;
}

static CubeMove rotate_move_by(const CubeMove move, const face_index_t rotation_face_index, const direction_t rotation_direction) {
  CubeMove result = move;
  if (!same_axis(move.axis_face_index, rotation_face_index)) {
    const size_t index = neighbor_index(rotation_face_index, move.axis_face_index);
    result.axis_face_index = neighbor_face_index(rotation_face_index, index + rotation_direction);
  }
  return result;
}

static VALUE CubeAlgorithm_rotate_by(const VALUE self, const VALUE rotation_face_symbol, const VALUE direction) {
  const face_index_t rotation_face_index = face_index(rotation_face_symbol);
  const direction_t rotation_direction = NUM2INT(direction);
  const CubeAlgorithmData* data;
  GetInitializedCubeAlgorithmData(self, data);
  CubeAlgorithmData* rotated_data;
  const VALUE rotated = TypedData_Make_Struct(CubeAlgorithmClass, CubeAlgorithmData, &CubeAlgorithmData_type, rotated_data);
  rotated_data->size = data->size;
  rotated_data->cube_size = data->cube_size;
  rotated_data->moves = malloc_moves(rotated_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    rotated_data->moves[i] = rotate_move_by(data->moves[i], rotation_face_index, rotation_direction);
  }
  return rotated;
}

static CubeMove mirror_move(const CubeMove move, const face_index_t normal_face_index) {
  CubeMove result = move;
  if (same_axis(move.axis_face_index, normal_face_index)) {
    result.axis_face_index = opposite_face_index(move.axis_face_index);
  }
  result.direction = opposite_face_index(move.axis_face_index);
  return result;
}

static VALUE CubeAlgorithm_mirror(const VALUE self, const VALUE normal_face_symbol) {
  const face_index_t normal_face_index = face_index(normal_face_symbol);
  const CubeAlgorithmData* data;
  GetInitializedCubeAlgorithmData(self, data);
  CubeAlgorithmData* mirrored_data;
  const VALUE mirrored = TypedData_Make_Struct(CubeAlgorithmClass, CubeAlgorithmData, &CubeAlgorithmData_type, mirrored_data);
  mirrored_data->size = data->size;
  mirrored_data->cube_size = data->cube_size;
  mirrored_data->moves = malloc_moves(mirrored_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    mirrored_data->moves[i] = mirror_move(data->moves[i], normal_face_index);
  }
  return mirrored;
}

static CubeMove invert_move(const CubeMove move) {
  CubeMove result = move;
  result.direction = invert_cube_direction(result.direction);
  return result;
}

static VALUE CubeAlgorithm_inverse(const VALUE self) {
  const CubeAlgorithmData* data;
  GetInitializedCubeAlgorithmData(self, data);
  CubeAlgorithmData* inverted_data;
  const VALUE inverted = TypedData_Make_Struct(CubeAlgorithmClass, CubeAlgorithmData, &CubeAlgorithmData_type, inverted_data);
  inverted_data->size = data->size;
  inverted_data->cube_size = data->cube_size;
  inverted_data->moves = malloc_moves(inverted_data->size);
  for (size_t i = 0; i < data->size; ++i) {
    inverted_data->moves[i] = invert_move(data->moves[data->size - 1 - i]);
  }
  return inverted;
}

static VALUE CubeAlgorithm_plus(const VALUE self, const VALUE other) {
  const CubeAlgorithmData* self_data;
  GetInitializedCubeAlgorithmData(self, self_data);
  const CubeAlgorithmData* other_data;
  GetInitializedCubeAlgorithmData(other, other_data);
  if (self_data->cube_size != other_data->cube_size) {
    rb_raise(rb_eArgError, "Cannot concatenate algorithms for different cube sizes %ld and %ld.", self_data->cube_size, other_data->cube_size);
  }
  CubeAlgorithmData* sum_data;
  const VALUE sum = TypedData_Make_Struct(CubeAlgorithmClass, CubeAlgorithmData, &CubeAlgorithmData_type, sum_data);
  sum_data->size = self_data->size + other_data->size;
  sum_data->cube_size = self_data->cube_size;
  sum_data->moves = malloc_moves(sum_data->size);
  for (size_t i = 0; i < self_data->size; ++i) {
    sum_data->moves[i] = self_data->moves[i];
  }
  for (size_t i = 0; i < other_data->size; ++i) {
    sum_data->moves[self_data->size + i] = other_data->moves[i];
  }
  return sum;
}

void init_cube_algorithm_class_under(const VALUE module) {
  slice_id = rb_intern("slice");
  face_id = rb_intern("face");
  CubeAlgorithmClass = rb_define_class_under(module, "CubeAlgorithm", rb_cObject);
  rb_define_alloc_func(CubeAlgorithmClass, CubeAlgorithm_alloc);
  rb_define_method(CubeAlgorithmClass, "initialize", CubeAlgorithm_initialize, 2);
  rb_define_method(CubeAlgorithmClass, "apply_to", CubeAlgorithm_apply_to, 1);
  rb_define_method(CubeAlgorithmClass, "rotate_by", CubeAlgorithm_rotate_by, 2);
  rb_define_method(CubeAlgorithmClass, "mirror", CubeAlgorithm_mirror, 1);
  rb_define_method(CubeAlgorithmClass, "inverse", CubeAlgorithm_inverse, 0);
  rb_define_method(CubeAlgorithmClass, "+", CubeAlgorithm_plus, 1);
}
