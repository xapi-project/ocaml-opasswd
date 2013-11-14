val shadow_file : string

type t = {
  name     : string;
  passwd   : string;
  last_chg : int64;
  min      : int64;
  max      : int64;
  warn     : int64;
  inact    : int64;
  expire   : int64;
  flag     : int;
}

val to_string : t -> string

type db = t list

val db_to_string : db -> string

val getspnam : string -> t option
val getspent : unit -> t option

val setspent : unit -> unit
val endspent : unit -> unit
val putspent : Passwd.file_descr -> t -> unit

val lckpwdf : unit -> bool
val ulckpwdf : unit -> bool

val with_lock : (unit -> 'a) -> 'a

val shadow_enabled : unit -> bool

val get_db : unit -> db
val update_db : db -> t -> db
val write_db : ?file:string -> db -> unit

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
