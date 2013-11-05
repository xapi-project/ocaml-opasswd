#include "common.h"

value val_spwd(struct spwd* sp) {
  CAMLparam0();
  CAMLlocal2(ret, tmp);

  ret = caml_alloc(9, 0);

  tmp = caml_copy_string(sp->sp_namp == NULL ? "" : sp->sp_namp);
  Store_field(ret, 0, tmp);

  tmp = caml_copy_string(sp->sp_pwdp == NULL ? "" : sp->sp_pwdp);
  Store_field(ret, 1, tmp);

  tmp = caml_copy_int64(sp->sp_lstchg);
  Store_field(ret, 2, tmp);

  tmp = caml_copy_int64(sp->sp_min);
  Store_field(ret, 3, tmp);

  tmp = caml_copy_int64(sp->sp_max);
  Store_field(ret, 4, tmp);

  tmp = caml_copy_int64(sp->sp_warn);
  Store_field(ret, 5, tmp);

  tmp = caml_copy_int64(sp->sp_inact);
  Store_field(ret, 6, tmp);

  tmp = caml_copy_int64(sp->sp_expire);
  Store_field(ret, 7, tmp);

  tmp = caml_copy_int64(sp->sp_flag);
  Store_field(ret, 8, tmp);

  CAMLreturn(ret);
}

struct spwd* spwd_val(value sp_val) {
  struct spwd* sp = malloc(sizeof(struct spwd));

  if (sp == NULL) {
    return NULL;
  }

  sp->sp_namp   = String_val(Field(sp_val, 0));
  sp->sp_pwdp   = String_val(Field(sp_val, 1));
  sp->sp_lstchg = Int64_val(Field(sp_val, 2));
  sp->sp_min    = Int64_val(Field(sp_val, 3));
  sp->sp_max    = Int64_val(Field(sp_val, 4));
  sp->sp_warn   = Int64_val(Field(sp_val, 5));
  sp->sp_inact  = Int64_val(Field(sp_val, 6));
  sp->sp_expire = Int64_val(Field(sp_val, 7));
  sp->sp_flag   = Int64_val(Field(sp_val, 8));

  return sp;
}

CAMLprim value stub_getspnam(value name_val) {
  CAMLparam1(name_val);
  CAMLlocal2(ret, tmp);

  char* name = String_val(name_val);
  struct spwd* sp = malloc(sizeof(struct spwd));

  sp = getspnam(name);

  if (sp == 0) {
    free(sp);
    caml_failwith("Can't access shadow file");
  }

  ret = val_spwd(sp);

  CAMLreturn(ret);
}

CAMLprim value stub_lckpwdf(value unit) {
  caml_release_runtime_system();
  int r = lckpwdf();
  caml_acquire_runtime_system();

  return (r == 0 ? Val_true : Val_false);
}

CAMLprim value stub_ulckpwdf(value unit) {
  caml_release_runtime_system();
  int r = ulckpwdf();
  caml_acquire_runtime_system();

  return (r == 0 ? Val_true : Val_false);
}

void putspent_common(value sp_val, FILE* fd) {
  struct spwd* sp = spwd_val(sp_val);

  if (sp == NULL) {
    caml_failwith("putspent: ENOMEM");
  }

  caml_release_runtime_system();
  int r = putspent(sp, fd);
  caml_acquire_runtime_system();

  free(sp);

  if (r != 0) {
    caml_failwith("Couldn't write to shadow file");
  }
}

CAMLprim value stub_putspent_fd(value f, value sp_val) {
  CAMLparam2(f, sp_val);

  FILE* fd = FILE_val(f);

  if (fd == NULL) {
    caml_failwith("Can't open shadow file for writing");
  }

  putspent_common(sp_val, fd);

  CAMLreturn(Val_unit);
}

CAMLprim value stub_setspent(value unit) {
  setspent();
  return Val_unit;
}

CAMLprim value stub_endspent(value unit) {
  endspent();
  return Val_unit;
}

CAMLprim value stub_getspent(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(ret);

  struct spwd* sp = getspent();

  if (sp == NULL) {
    // None
    return Val_int(0);
  } else {
    // Some sp
    ret = alloc_small(1, 0);
    Field(ret, 0) = val_spwd(sp);
    CAMLreturn(ret);
  }
}

/* Local Variables: */
/* indent-tabs-mode: nil */
/* End: */
