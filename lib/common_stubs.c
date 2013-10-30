#include "common.h"

CAMLprim value stub_fopen(value f) {
  CAMLparam1(f);
  CAMLlocal1(ret);

  FILE* fd = fopen(String_val(f), FILE_MODE);

  if (fd == NULL) {
    caml_failwith("stub_fopen: Couldn't open file");
  }

  ret = Val_FILE(fd);

  CAMLreturn(ret);
}

CAMLprim value stub_fclose(value f) {
  CAMLparam1(f);

  FILE* fd = FILE_val(f);
  int r = fclose(fd);

  if (r != 0) {
    caml_failwith("stub_fclose: Couldn't close fd");
  }

  CAMLreturn(Val_unit);
}

/* Local Variables: */
/* indent-tabs-mode: nil */
/* End: */
