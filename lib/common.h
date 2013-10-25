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

CAMLprim value stub_fopen(value f);
CAMLprim value stub_fclose(value f);

#define FILE_val(f) (FILE*) Int64_val(f);
#define Val_FILE(v) caml_copy_int64((int64_t)v);

#define FILE_MODE "r+"
