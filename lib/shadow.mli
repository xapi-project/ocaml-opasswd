type spwd = {
  name : string;
  pwd : string;
  last_chg : int64;
  min : int64;
  max : int64;
  warn : int64;
  inact : int64;
  expire : int64;
  flag : int64;
}

type spwd_db = spwd list

external getspnam : string -> spwd = "stub_getspnam"
external putspent : spwd -> Unix.file_descr -> unit = "stub_putspent"

external getspent : unit -> spwd = "stub_getspent"
external setspent : unit -> unit = "stub_setspent"
external endpsent : unit -> unit = "stub_endspent"

external lckpwdf : unit -> bool = "stub_lckpwdf"
external ulckpwdf : unit -> bool = "stub_ulckpwdf"

val passwd_file : string
val shadow_file : string

val shadow_enabled : unit -> bool
