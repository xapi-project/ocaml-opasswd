val passwd_file : string

type ent = {
  name : string;
  passwd : string;
  uid : int;
  gid : int;
  gecos : string;
  dir : string;
  shell : string;
}

val to_string : ent -> string

type db = ent list

val db_to_string : db -> string

type file_descr

external getpwnam : string -> ent = "stub_getpwnam"
external getpwuid : int -> ent = "stub_getpwuid"

external getpwent : unit -> ent option = "stub_getpwent"
external setpwent : unit -> unit = "stub_setpwent"
external endpwent : unit -> unit = "stub_endpwent"
external putpwent : file_descr -> ent -> unit = "stub_putpwent"

val open_passwd : ?file:string -> unit -> file_descr
val close_passwd : file_descr -> unit


val get_db : unit -> db
val update_db : db -> ent -> db
val write_db : ?file:string -> db -> unit
