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

type db = ent list

type file_descr = int64

external getpwnam : string -> ent = "stub_getpwnam"
external getpwuid : int -> ent = "stub_getpwuid"

external setpwent : unit -> unit = "stub_setpwent"
external getpwent : unit -> ent option = "stub_getpwuid"
external endpwent : unit -> unit = "stub_endpwent"

external stub_fopen : string -> file_descr = "stub_fopen"
external stub_fclose : file_descr -> unit = "stub_fclose"

val open_passwd : ?file:string -> unit -> file_descr
val close_passwd : file_descr -> unit

val to_string : ent -> string

val putpwent : 'a -> 'b -> unit
val get_db : unit -> ent list
val write_db : ?file:string -> 'a -> unit
