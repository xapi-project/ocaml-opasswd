#include <sys/types.h>
#include <shadow.h>
#include <pwd.h>

#include <errno.h>
#include <malloc.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>

#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/threads.h>

#define SHADOW_FILE "/etc/shadow"

value val_passwd(struct passwd* pw) {
  value ret = caml_alloc(7, 0);

  Store_field(ret, 0, caml_copy_string(pw->pw_name == NULL ? "" : pw->pw_name));
  Store_field(ret, 1, caml_copy_string(pw->pw_passwd == NULL ? "" : pw->pw_passwd));
  Store_field(ret, 2, Val_int(pw->pw_uid));
  Store_field(ret, 3, Val_int(pw->pw_gid));
  Store_field(ret, 4, caml_copy_string(pw->pw_gecos == NULL ? "" : pw->pw_gecos));
  Store_field(ret, 5, caml_copy_string(pw->pw_dir == NULL ? "" : pw->pw_dir));
  Store_field(ret, 6, caml_copy_string(pw->pw_shell == NULL ? "" : pw->pw_shell));

  return ret;
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
    return Val_int(0);
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

/* Local Variables: */
/* indent-tabs-mode: nil */
/* End: */
