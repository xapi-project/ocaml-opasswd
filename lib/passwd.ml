let passwd_file = "/etc/passwd"

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
external putpwent : file_descr -> ent -> unit = "stub_putpwent"

external getpwent : unit -> ent option = "stub_getpwent"
external setpwent : unit -> unit = "stub_setpwent"
external endpwent : unit -> unit = "stub_endpwent"

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

let db_to_string db = db
  |> List.map to_string
  |> String.concat "\n"

external stub_fopen : string -> file_descr = "stub_fopen"
external stub_fclose : file_descr -> unit = "stub_fclose"

let open_passwd ?(file=passwd_file) () =
  (* try *)
    stub_fopen file
  (* with _ -> raise Unix.(Unix_error (EAGAIN, "open_shadow", file)) *)

let close_passwd fd =
  (* try *)
    stub_fclose fd
  (* with _ -> raise Unix.(Unix_error (EBADF, "close_shadow", "")) *)

(* let putpwent fd ent = putpwent ent fd *)

let get_db () =
  let rec loop acc =
    match getpwent () with
    | None -> endpwent () ; acc
    | Some pw -> loop (pw :: acc)
  in
  setpwent () ;
  loop [] |> List.rev

let rec update_db db ent =
  let rec loop acc = function
    | [] -> List.rev acc
    | e :: es when e.name = ent.name -> loop (ent::acc) es
    | e :: es -> loop (e::acc) es
  in loop [] db

let write_db ?(file=passwd_file) db =
  let fd = open_passwd ~file () in
  List.iter (putpwent fd) db;
  close_passwd fd

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
