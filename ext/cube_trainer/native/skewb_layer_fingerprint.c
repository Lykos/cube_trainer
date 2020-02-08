#include "skewb_layer_fingerprint.h"

#include <stdint.h>

#include "skewb_state.h"
#include "skewb_coordinate.h"
#include "utils.h"

typedef enum {
  BOTH_MISSING,
  ONE_ORIENTED_ONE_MISSING,
  ONE_TWISTED_ONE_MISSING,
  BOTH_ORIENTED_AND_ADJACENT,
  BOTH_ORIENTED_AND_OPPOSITE,
  ONE_ORIENTED_ONE_TWISTED_AND_ADJACENT,
  ONE_ORIENTED_ONE_TWISTED_AND_OPPOSITE,
  BOTH_TWISTED_SAME_WAY_AND_ADJACENT,
  BOTH_TWISTED_SAME_WAY_AND_OPPOSITE,
  BOTH_TWISTED_OPPOSITE_WAY_AND_ADJACENT,
  BOTH_TWISTED_OPPOSITE_WAY_AND_OPPOSITE,
  NUM_CORNER_PAIR_TYPES,
} CornerPairType;

typedef struct {
  VALUE stickers[3];
} ActualCornerStickers;

static ID plus = 868;
static ID times = 848;

#define max_corner_pair_group_size 8

typedef struct {
  Corner corner_pairs[max_corner_pair_group_size][2];
  int num_corner_pairs;
  // Number of different group fingerprints. This can be used to merge several group fingerprints.
  int num_group_fingerprints;
} CornerPairGroup;

#define num_corner_pair_groups 7

static CornerPairGroup corner_pair_groups[cube_faces][num_corner_pair_groups];

static ActualCornerStickers get_actual_corner_stickers(const SkewbStateData* const skewb_state,
                                                       const Corner corner) {
  ActualCornerStickers result;
  for (size_t i = 0; i < 3; ++i) {
    result.stickers[i] = skewb_state->stickers[corner_sticker_index(rotated_corner(corner, i))];
  }
  return result;
}

static bool has_color_at(const ActualCornerStickers actual, const size_t index, const VALUE color) {
  return color_eq(actual.stickers[index], color);
}

typedef struct {
  int layer_index;
  bool is_oriented;
  bool is_present;
} ActualCornerStickersInfo;

static ActualCornerStickersInfo get_info(const ActualCornerStickers actual, const VALUE layer_color) {
  ActualCornerStickersInfo info = {-1, 0, 0};
  for (size_t i = 0; i < 3; ++i) {
    if (has_color_at(actual, i, layer_color)) {
      info.layer_index = i;
      info.is_present = 1;
      if (i == 0) {
        info.is_oriented = 1;
      }
      break;
    }
  }
  return info;
}

typedef struct {
  ActualCornerStickers actual;
  ActualCornerStickersInfo info;
} AnnotatedActualCornerStickers;

static AnnotatedActualCornerStickers get_annotated(const SkewbStateData* const skewb_state,
                                                      const Corner corner,
                                                      const VALUE layer_color) {
  AnnotatedActualCornerStickers annotated;
  annotated.actual = get_actual_corner_stickers(skewb_state, corner);
  annotated.info = get_info(annotated.actual, layer_color);
  return annotated;
}

static bool is_adjacent(const AnnotatedActualCornerStickers annotated_a, const AnnotatedActualCornerStickers annotated_b) {
  for (size_t i = 0; i < 3; ++i) {
    if (i == annotated_a.info.layer_index) {
      continue;
    }
    const VALUE color_a = annotated_a.actual.stickers[i];
    for (size_t j = 0; j < 3; ++j) {
      if (j == annotated_b.info.layer_index) {
        continue;
      }
      const VALUE color_b = annotated_b.actual.stickers[j];
      if (color_eq(color_a, color_b)) {
        return TRUE;
      }
    }
  }
  return FALSE;
}

// Returns the basic type (i.e. without taking into account whether its adjacent or opposite corners) for two present corners.
static CornerPairType get_basic_type(const AnnotatedActualCornerStickers annotated_a, const AnnotatedActualCornerStickers annotated_b, const int num_oriented) {
  // Note that we always use the adjacent variations.
  switch (num_oriented) {
  case 2:
    return BOTH_ORIENTED_AND_ADJACENT;
  case 1:
    return ONE_ORIENTED_ONE_TWISTED_AND_ADJACENT;
  case 0: {
    if (annotated_a.info.layer_index == annotated_b.info.layer_index) {
      return BOTH_TWISTED_SAME_WAY_AND_ADJACENT;
    } else {
      return BOTH_TWISTED_OPPOSITE_WAY_AND_ADJACENT;
    }
  }
  default: rb_raise(rb_eRuntimeError, "invalid num oriented");
  }
}

static CornerPairType corner_pair_type(const SkewbStateData* const skewb_state,
                                       const Corner corner_a,
                                       const Corner corner_b,
                                       const VALUE layer_color) {
  const AnnotatedActualCornerStickers annotated_a = get_annotated(skewb_state, corner_a, layer_color);
  const AnnotatedActualCornerStickers annotated_b = get_annotated(skewb_state, corner_b, layer_color);
  const int num_oriented = annotated_a.info.is_oriented + annotated_b.info.is_oriented;
  const int num_present = annotated_a.info.is_present + annotated_b.info.is_present;
  switch (num_present) {
  case 0: return BOTH_MISSING;
  case 1:
    switch (num_oriented) {
    case 0: return ONE_TWISTED_ONE_MISSING;
    case 1: return ONE_ORIENTED_ONE_MISSING;
    default: rb_raise(rb_eRuntimeError, "invalid num oriented");   
    }
  case 2: break;  // Continue function execution.
  default: rb_raise(rb_eRuntimeError, "invalid num present");
  }
  const CornerPairType basic_type = get_basic_type(annotated_a, annotated_b, num_oriented);
  return is_adjacent(annotated_a, annotated_b) ? basic_type : basic_type + 1;
}

static uint64_t corner_pair_group_fingerprint(const SkewbStateData* const skewb_state, const CornerPairGroup group, const VALUE layer_color) {
  int corner_pair_type_counts[NUM_CORNER_PAIR_TYPES];
  memset(corner_pair_type_counts, 0, NUM_CORNER_PAIR_TYPES * sizeof(int));
  for (size_t i = 0; i < group.num_corner_pairs; ++i) {
    ++corner_pair_type_counts[corner_pair_type(skewb_state, group.corner_pairs[i][0], group.corner_pairs[i][1], layer_color)];
  }
  uint64_t fingerprint = 0;
  for (size_t i = 0; i < NUM_CORNER_PAIR_TYPES; ++i) {
    fingerprint *= (group.num_corner_pairs + 1);
    fingerprint |= corner_pair_type_counts[i];
  }
  return fingerprint;
}

static VALUE skewb_layer_fingerprint(const VALUE module, const VALUE skewb_state, const VALUE face_symbol) {
  const SkewbStateData* data;
  GetSkewbStateData(skewb_state, data);
  const face_index_t layer_face_index = face_index(face_symbol);
  const VALUE layer_color = data->stickers[center_sticker_index(layer_face_index)];
  // We use a Ruby integer for accumulation because the result will overflow.
  VALUE rb_fingerprint = INT2NUM(0);
  int64_t last_multiplier = 0;
  for (size_t i = 0; i < num_corner_pair_groups; ++i) {
    if (last_multiplier > 0) {
      rb_fingerprint = rb_funcall(rb_fingerprint, times, 1, INT2NUM(last_multiplier));
    }
    const CornerPairGroup group = corner_pair_groups[layer_face_index][i];
    const uint64_t group_fingerprint = corner_pair_group_fingerprint(data, group, layer_color);
    const VALUE rb_group_fingerprint = LONG2NUM(group_fingerprint);
    rb_fingerprint = rb_funcall(rb_fingerprint, plus, 1, rb_group_fingerprint);
    last_multiplier = group.num_group_fingerprints;
  }
  return rb_fingerprint;
}

typedef struct {
  Corner corners[4];
} FaceCorners;

static FaceCorners get_face_corners(const face_index_t face_index) {
  FaceCorners result;
  for (size_t i = 0; i < 4; ++i) {
    result.corners[i].face_indices[0] = face_index;
    result.corners[i].face_indices[1] = neighbor_face_index(face_index, i);
    result.corners[i].face_indices[2] = neighbor_face_index(face_index, i + 1);
  }
  return result;
}

static CornerPairGroup adjacent_corner_pairs_group(const FaceCorners corners) {
  CornerPairGroup result;
  result.num_corner_pairs = 4;
  for (size_t i = 0; i < 4; ++i) {
    result.corner_pairs[i][0] = corners.corners[i];
    result.corner_pairs[i][1] = corners.corners[(i + 1) % 4];
  }
  return result;
}

static CornerPairGroup opposite_corner_pairs_group(const FaceCorners corners) {
  CornerPairGroup result;
  result.num_corner_pairs = 2;
  for (size_t i = 0; i < 2; ++i) {
    result.corner_pairs[i][0] = corners.corners[i];
    result.corner_pairs[i][1] = corners.corners[i + 2];
  }
  return result;
}

static CornerPairGroup stacked_corner_pairs_group(const FaceCorners top_corners, const FaceCorners bottom_corners) {
  CornerPairGroup result;
  result.num_corner_pairs = 4;
  for (size_t i = 0; i < 4; ++i) {
    result.corner_pairs[i][0] = top_corners.corners[i];
    result.corner_pairs[i][1] = bottom_corners.corners[3 - i];
  }
  return result;
}

static CornerPairGroup short_diagonal_corner_pairs_group(const FaceCorners top_corners, const FaceCorners bottom_corners) {
  CornerPairGroup result;
  result.num_corner_pairs = 8;
  for (size_t i = 0; i < 8; ++i) {
    const size_t top_index = i / 2;
    const size_t bottom_index = (top_index + 1 + (i % 2) * 2) % 4;
    result.corner_pairs[i][0] = top_corners.corners[top_index];
    result.corner_pairs[i][1] = bottom_corners.corners[bottom_index];
  }
  return result;
}

static CornerPairGroup long_diagonal_corner_pairs_group(const FaceCorners top_corners, const FaceCorners bottom_corners) {
  CornerPairGroup result;
  result.num_corner_pairs = 4;
  for (size_t i = 0; i < 4; ++i) {
    result.corner_pairs[i][0] = top_corners.corners[i];
    result.corner_pairs[i][1] = bottom_corners.corners[(3 - i + 2) % 4];
  }
  return result;
}

static void init_corner_pair_groups_for_face_index(const face_index_t layer_face_index) {
  const FaceCorners top_corners = get_face_corners(layer_face_index);
  const FaceCorners bottom_corners = get_face_corners(opposite_face_index(layer_face_index));
  if (top_corners.corners[0].face_indices[1] == top_corners.corners[0].face_indices[2] &&
      top_corners.corners[0].face_indices[2] == top_corners.corners[0].face_indices[1]) {
    rb_raise(rb_eRuntimeError, "Failed initialization due to wrong order of corners.");
  }
  corner_pair_groups[layer_face_index][0] = adjacent_corner_pairs_group(top_corners);
  corner_pair_groups[layer_face_index][1] = opposite_corner_pairs_group(top_corners);
  corner_pair_groups[layer_face_index][2] = adjacent_corner_pairs_group(bottom_corners);
  corner_pair_groups[layer_face_index][3] = opposite_corner_pairs_group(bottom_corners);
  corner_pair_groups[layer_face_index][4] = stacked_corner_pairs_group(top_corners, bottom_corners);
  corner_pair_groups[layer_face_index][5] = short_diagonal_corner_pairs_group(top_corners, bottom_corners);
  corner_pair_groups[layer_face_index][6] = long_diagonal_corner_pairs_group(top_corners, bottom_corners);

  for (int i = 0; i < num_corner_pair_groups; ++i) {
    CornerPairGroup* const group = &corner_pair_groups[layer_face_index][i];
    group->num_group_fingerprints = iexp(group->num_corner_pairs + 1, NUM_CORNER_PAIR_TYPES);
  }
}

static void init_corner_pair_groups() {
  for (face_index_t layer_face_index = 0; layer_face_index < cube_faces; ++layer_face_index) {
    init_corner_pair_groups_for_face_index(layer_face_index);
  }
}

void init_skewb_layer_fingerprint_method_under(const VALUE module) {
  plus = rb_intern("+");
  times = rb_intern("*");
  rb_define_singleton_method(module, "skewb_layer_fingerprint", skewb_layer_fingerprint, 2);
}
