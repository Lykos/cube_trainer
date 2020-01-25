#pragma once

#include <ruby.h>

typedef int FACE_INDEX;

static const FACE_INDEX cube_faces = 6;

static const FACE_INDEX U = 0;
static const FACE_INDEX F = 1;
static const FACE_INDEX R = 2;
static const FACE_INDEX B = 3;
static const FACE_INDEX L = 4;
static const FACE_INDEX D = 5;

FACE_INDEX face_index(VALUE face_symbol);

VALUE face_symbol(FACE_INDEX face_index);

FACE_INDEX axis_index(FACE_INDEX face_index);

FACE_INDEX opposite_face_index(FACE_INDEX face_index);

void init_face_symbols();
