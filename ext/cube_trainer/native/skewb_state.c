#include "skewb_state.h"

VALUE SkewbStateClass = Qnil;

typedef struct {
  VALUE stickers[total_skewb_stickers];
} SkewbStateData;

static void SkewbStateData_mark(void* const ptr) {
  const SkewbStateData* data = ptr;
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    rb_gc_mark(data->stickers[i]);
  }
}

static size_t SkewbStateData_size(const void* const ptr) {
  return sizeof(SkewbStateData);
}

const rb_data_type_t SkewbStateData_type = {
  "SkewbTrainer::Native::SkewbStateData",
  {SkewbStateData_mark, NULL, SkewbStateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#define GetSkewbStateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), SkewbStateData, &SkewbStateData_type, (data)); \
  } while (0)

static VALUE SkewbState_alloc(const VALUE klass) {
  SkewbStateData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbStateData, &SkewbStateData_type, data);
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    data->stickers[i] = Qnil;
  }
}

static int SkewbState_replace_face(const VALUE key, const VALUE value, const VALUE self) {
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  const face_index_t on_face_index = face_index(key);
  for (size_t i = 0; i < skewb_stickers_per_face; ++i) {
    data->stickers[on_face_index * skewb_stickers_per_face + i] = value;
  }
  return ST_CONTINUE;
}

static VALUE SkewbState_initialize(const VALUE self, const VALUE stickers) {
  Check_Type(stickers, T_HASH);
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  if (RHASH_SIZE(stickers) != skewb_faces) {
    rb_raise(rb_eTypeError, "Skewbs must have %d faces. Got %ld.", skewb_faces, RHASH_SIZE(stickers));
  }
  rb_hash_foreach(stickers, SkewbState_replace_face, self);
  return self;
}

static VALUE SkewbState_hash(const VALUE self) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)SkewbState_hash);
  for (size_t i = 0; i < total_skewb_stickers; i++) {
    const VALUE sub_hash = rb_hash(data->stickers[i]);
    hash = rb_hash_uint(hash, NUM2LONG(sub_hash));
  }
  return ST2FIX(rb_hash_end(hash));
}

static VALUE SkewbState_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const SkewbStateData* self_data;
  GetSkewbStateData(self, self_data);
  const SkewbStateData* other_data;
  GetSkewbStateData(self, other_data);
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    if (self_data->stickers[i] != other_data->stickers[i]) {
      return Qfalse;
    }
  }
  return Qtrue;
}

static VALUE SkewbState_dup(const VALUE self) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);
  SkewbStateData* dupped_data;
  const VALUE dupped = TypedData_Make_Struct(rb_obj_class(self), SkewbStateData, &SkewbStateData_type, dupped_data);
  *dupped_data = *data;
  return dupped;
}

void init_skewb_state_class_under(const VALUE module) {
  SkewbStateClass = rb_define_class_under(module, "SkewbState", rb_cObject);
  rb_define_alloc_func(SkewbStateClass, SkewbState_alloc);
  rb_define_method(SkewbStateClass, "initialize", SkewbState_initialize, 6);
  rb_define_method(SkewbStateClass, "hash", SkewbState_hash, 0);
  rb_define_method(SkewbStateClass, "eql?", SkewbState_eql, 1);
  rb_define_alias(SkewbStateClass, "==", "eql?");
  rb_define_method(SkewbStateClass, "dup", SkewbState_dup, 0);
}
