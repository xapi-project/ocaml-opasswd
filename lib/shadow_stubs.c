#include <sys/types.h>
#include <shadow.h>
#include <pwd.h>

#include <unistd.h>
#include <crypt.h>

#include <errno.h>
#include <malloc.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>

#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/threads.h>

#define PASSWD_FILE "/etc/passwd"
#define SHADOW_FILE "/etc/shadow"

CAMLprim value val_spwd(struct spwd* sp) {
	//CAMLlocal1(ret);
	value ret, tmp;

	// type spwd
	ret = caml_alloc(9, 0);

	// spwd.name
	tmp = caml_copy_string(sp->sp_namp);
	Store_field(ret, 0, tmp);

	// spwd.pwd
	tmp = caml_copy_string(sp->sp_pwdp);
	Store_field(ret, 1, tmp);

	// spwd.sp_lstchg
	tmp = caml_copy_int64(sp->sp_lstchg);
	Store_field(ret, 2, tmp);

	// spwd.sp_min
	tmp = caml_copy_int64(sp->sp_min);
	Store_field(ret, 3, tmp);

	// spwd.sp_max
	tmp = caml_copy_int64(sp->sp_max);
	Store_field(ret, 4, tmp);

	// spwd.sp_warn
	tmp = caml_copy_int64(sp->sp_warn);
	Store_field(ret, 5, tmp);

	// spwd.sp_inact
	tmp = caml_copy_int64(sp->sp_inact);
	Store_field(ret, 6, tmp);

	// spwd.sp_expire
	tmp = caml_copy_int64(sp->sp_expire);
	Store_field(ret, 7, tmp);

	// spwd.sp_flag
	tmp = caml_copy_int64(sp->sp_flag);
	Store_field(ret, 8, tmp);

	//CAMLreturn(ret);
	return ret;
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

CAMLprim value stub_putspent(value sp_val, value f) {
	CAMLparam1(sp_val);

	int f2 = dup(Int_val(f));
	FILE* fd = fdopen(f2, "w");

	if (fd == NULL) {
		caml_failwith("Can't open file for writing");
	}

	struct spwd* sp = malloc(sizeof(struct spwd));

	if (sp == NULL) {
		fclose(fd);
		caml_failwith("ENOMEM");
	}

  sp->sp_namp		= String_val(Field(sp_val, 0));
  sp->sp_pwdp		= String_val(Field(sp_val, 1));
  sp->sp_lstchg = Int64_val(Field(sp_val, 2));
  sp->sp_min		= Int64_val(Field(sp_val, 3));
  sp->sp_max		= Int64_val(Field(sp_val, 4));
  sp->sp_warn		= Int64_val(Field(sp_val, 5));
  sp->sp_inact	= Int64_val(Field(sp_val, 6));
  sp->sp_expire = Int64_val(Field(sp_val, 7));
  sp->sp_flag		= Int64_val(Field(sp_val, 8));

	caml_release_runtime_system();
	int r = putspent(sp, fd);
	caml_acquire_runtime_system();

	if (r != 0) {
		fclose(fd);
		free(sp);
		caml_failwith("Couldn't write to shadow file");
	}

	printf("* STUB r == %d\n", r);

	fclose(fd);
	free(sp);

	CAMLreturn(Val_unit);
}

CAMLprim value stub_setspent(value unit) {
	setspent();
	return Val_unit;
}

/* CAMLprim value stub_getspent(value unit) { */
/* 	CAMLlocal1(ret); */


/* } */
