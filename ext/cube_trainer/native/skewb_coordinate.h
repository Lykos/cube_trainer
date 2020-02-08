#pragma once

#include <ruby.h>

#include "face_symbols.h"

#define skewb_faces cube_faces
#define skewb_stickers_per_face 5
#define total_skewb_stickers skewb_stickers_per_face * skewb_faces

typedef enum {
  CENTER,
  CORNER,
} SkewbPartType;

typedef struct {
  face_index_t face_indices[3];
} Corner;

Corner rotated_corner(Corner corner, int rotation);

size_t corner_sticker_index(Corner corner);

size_t center_sticker_index(face_index_t on_face_index);

size_t SkewbCoordinate_sticker_index(VALUE self);

Corner extract_corner(VALUE face_symbols);
 
typedef struct {
  Corner corners[4];
} FaceCorners;

FaceCorners get_face_corners(face_index_t face_index);

void init_skewb_coordinate_class_under(VALUE module);
