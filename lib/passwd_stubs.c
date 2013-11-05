#include "common.h"

value val_passwd(struct passwd* pw) {
  CAMLparam0();
  CAMLlocal2(ret, tmp);

  ret = caml_alloc(7, 0);

  tmp = caml_copy_string(pw->pw_name == NULL ? "" : pw->pw_name);
  Store_field(ret, 0, tmp);

  tmp = caml_copy_string(pw->pw_passwd == NULL ? "" : pw->pw_passwd);
  Store_field(ret, 1, tmp);

  Store_field(ret, 2, Val_int(pw->pw_uid));
  Store_field(ret, 3, Val_int(pw->pw_gid));

  tmp = caml_copy_string(pw->pw_gecos == NULL ? "" : pw->pw_gecos);
  Store_field(ret, 4, tmp);

  tmp = caml_copy_string(pw->pw_dir == NULL ? "" : pw->pw_dir);
  Store_field(ret, 5, tmp);

  tmp = caml_copy_string(pw->pw_shell == NULL ? "" : pw->pw_shell);
  Store_field(ret, 6, tmp);

  CAMLreturn(ret);
}

struct passwd* passwd_val(value val) {
  struct passwd* pw = malloc(sizeof(struct passwd));

  if (pw == NULL) {
    return NULL;
  }

  pw->pw_name   = String_val(Field(val, 0));
  pw->pw_passwd = String_val(Field(val, 1));
  pw->pw_uid    = Int_val(Field(val, 2));
  pw->pw_gid    = Int_val(Field(val, 3));
  pw->pw_gecos  = String_val(Field(val, 4));
  pw->pw_dir    = String_val(Field(val, 5));
  pw->pw_shell  = String_val(Field(val, 6));

  return pw;
}

CAMLprim value stub_setpwent(value unit) {
  setpwent();
  return Val_unit;
}

CAMLprim value stub_endpwent(value unit) {
  endpwent();
  return Val_unit;
}

CAMLprim value stub_getpwent(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(ret);

  struct passwd* pw = getpwent();

  if (pw == NULL) {
    // None
    CAMLreturn(Val_int(0));
  } else {
    // Some pw
    ret = alloc_small(1, 0);
    Field(ret, 0) = val_passwd(pw);
    CAMLreturn(ret);
  }
}

// from getpwnam man page
CAMLprim value stub_getpwnam(value val_name) {
  CAMLparam1(val_name);
  CAMLlocal1(ret);

  struct passwd pwd;
  struct passwd *result;
  char *buf, *name;
  size_t bufsize;

  name = String_val(val_name);

  bufsize = sysconf(_SC_GETPW_R_SIZE_MAX);
  if (bufsize == -1)          /* Value was indeterminate */
    bufsize = 16384;        /* Should be more than enough */

  buf = malloc(bufsize);
  if (buf == NULL) {
    caml_failwith("stub_getpwnam: ENOMEM");
  }

  int r = getpwnam_r(name, &pwd, buf, bufsize, &result);
  if (result == NULL) {
    if (r == 0) {
      caml_failwith("stub_getpwnam: Not found");
    } else {
      // TODO better error reporting
      caml_failwith("stub_getpwnam: Not found");
    }
  }

  ret = val_passwd(result);
  CAMLreturn(ret);
}

CAMLprim value stub_getpwuid(value val_uid) {
  CAMLparam1(val_uid);
  CAMLlocal1(ret);

  struct passwd pwd;
  struct passwd *result;
  char *buf;
  size_t bufsize;

  uid_t uid = (uid_t) Int_val(val_uid);

  bufsize = sysconf(_SC_GETPW_R_SIZE_MAX);
  if (bufsize == -1)          /* Value was indeterminate */
    bufsize = 16384;        /* Should be more than enough */

  buf = malloc(bufsize);
  if (buf == NULL) {
    caml_failwith("stub_getpwuid: ENOMEM");
  }

  int r = getpwuid_r(uid, &pwd, buf, bufsize, &result);
  if (result == NULL) {
    if (r == 0) {
      caml_failwith("stub_getpwuid: Not found");
    } else {
      // TODO better error reporting
      caml_failwith("stub_getpwuid: Not found");
    }
  }

  ret = val_passwd(result);
  CAMLreturn(ret);
}

CAMLprim value stub_putpwent(value val_fd, value val_ent) {
  CAMLparam2(val_fd, val_ent);

  struct passwd* pw = passwd_val(val_ent);
  FILE* fd = FILE_val(val_fd);

  if (fd == NULL) {
    caml_failwith("Can't open passwd file for writing");
  }

  if (pw == NULL) {
    caml_failwith("putpwent: ENOMEM");
  }

  caml_release_runtime_system();
  int r = putpwent(pw, fd);
  caml_acquire_runtime_system();

  free(pw);

  if (r != 0) {
    caml_failwith("Couldn't write to passwd file");
  }

  CAMLreturn(Val_unit);
}

/* Local Variables: */
/* indent-tabs-mode: nil */
/* End: */
