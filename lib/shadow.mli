val shadow_file : string

type ent = {
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

val to_string : ent -> string

type db = ent list

val db_to_string : db -> string

type file_descr

external getspnam : string -> ent = "stub_getspnam"

external getspent : unit -> ent option = "stub_getspent"
external setspent : unit -> unit = "stub_setspent"
external endspent : unit -> unit = "stub_endspent"
external putspent : file_descr -> ent -> unit = "stub_putspent_fd"

external lckpwdf : unit -> bool = "stub_lckpwdf"
external ulckpwdf : unit -> bool = "stub_ulckpwdf"

val with_lock : (unit -> 'a) -> 'a

val open_shadow : ?file:string -> unit -> file_descr
val close_shadow : file_descr -> unit


val shadow_enabled : unit -> bool

val get_db : unit -> db
val update_db : db -> ent -> db
val write_db : ?file:string -> db -> unit

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
