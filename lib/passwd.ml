open Ctypes
open Foreign

type file_descr = unit ptr
let file_descr : file_descr typ = ptr void

let fopen =
  foreign ~check_errno:true "fopen" (string @-> string @-> returning file_descr)
let fclose' = foreign ~check_errno:true "fclose" (file_descr @-> returning int)
let fclose fd = fclose' fd |> ignore

type t = {
  name   : string;
  passwd : string;
  (* According to bits/typesizes.h uid_t and gid_t are uint32 *)
  uid    : int; (* uid    : uid_t; *)
  gid    : int; (* gid    : gid_t; *)
  gecos  : string;
  dir    : string;
  shell  : string;
}

type db = t list

type passwd_t

let passwd_t : passwd_t structure typ = structure "passwd"

let pw_name   = field passwd_t "pw_name" string
let pw_passwd = field passwd_t "pw_passwd" string
let pw_uid    = field passwd_t "pw_uid" uint32_t
let pw_gid    = field passwd_t "pw_gid" uint32_t
let pw_gecos  = field passwd_t "pw_gecos" string
let pw_dir    = field passwd_t "pw_dir" string
let pw_shell  = field passwd_t "pw_shell" string

let () = seal passwd_t

let from_passwd_t pw = {
  name   = getf !@pw pw_name;
  passwd = getf !@pw pw_passwd;
  uid    = getf !@pw pw_uid |> Unsigned.UInt32.to_int;
  gid    = getf !@pw pw_gid |> Unsigned.UInt32.to_int;
  gecos  = getf !@pw pw_gecos;
  dir    = getf !@pw pw_dir;
  shell  = getf !@pw pw_shell;
}

let from_passwd_t_opt = function
  | None -> None
  | Some pw -> Some (from_passwd_t pw)

let to_passwd_t pw =
  let pw_t : passwd_t structure = make passwd_t in
  setf pw_t pw_name pw.name;
  setf pw_t pw_passwd pw.passwd;
  setf pw_t pw_uid (Unsigned.UInt32.of_int pw.uid);
  setf pw_t pw_gid (Unsigned.UInt32.of_int pw.gid);
  setf pw_t pw_gecos pw.gecos;
  setf pw_t pw_dir pw.dir;
  setf pw_t pw_shell pw.shell;
  pw_t

let passwd_file = "/etc/passwd"

let getpwnam' =
  foreign ~check_errno:true "getpwnam" (string @-> returning (ptr_opt passwd_t))
let getpwnam name = getpwnam' name |> from_passwd_t_opt

let getpwuid' =
  foreign ~check_errno:true "getpwuid" (int @-> returning (ptr_opt passwd_t))
let getpwuid uid = getpwuid' uid |> from_passwd_t_opt

let getpwent' =
  foreign ~check_errno:true "getpwent" (void @-> returning (ptr_opt passwd_t))
let getpwent () = getpwent' () |> from_passwd_t_opt

let setpwent = foreign ~check_errno:true "setpwent" (void @-> returning void)
let endpwent = foreign ~check_errno:true "endpwent" (void @-> returning void)

let putpwent' =
  foreign ~check_errno:true "putpwent" (ptr passwd_t @-> file_descr @-> returning int)
let putpwent fd pw = putpwent' (to_passwd_t pw |> addr) fd |> ignore

let get_db () =
  let rec loop acc =
    match getpwent () with
    | None -> endpwent () ; acc
    | Some pw -> loop (pw :: acc)
  in
  setpwent () ;
  loop [] |> List.rev

let update_db db ent =
  let rec loop acc = function
    | [] -> List.rev acc
    | e :: es when e.name = ent.name -> loop (ent::acc) es
    | e :: es -> loop (e::acc) es
  in loop [] db

let write_db ?(file=passwd_file) db =
  let fd = fopen file "r+" in
  List.iter (putpwent fd) db;
  fclose fd

let to_string p =
  let str i =
    if i >= 0
    then string_of_int i
    else "" in
  Printf.sprintf "%s:%s:%s:%s:%s:%s:%s"
    p.name
    p.passwd
    (str p.uid)
    (str p.gid)
    p.gecos
    p.dir
    p.shell

let db_to_string db =
  db
  |> List.map to_string
  |> String.concat "\n"

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
