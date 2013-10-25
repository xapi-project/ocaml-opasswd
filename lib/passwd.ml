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
external putpwent : ent -> file_descr -> unit = "stub_putpwent"

external setpwent : unit -> unit = "stub_setpwent"
external getpwent : unit -> ent option = "stub_getpwuid"
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

let putpwent fd ent = ()

let get_db () =
  let rec loop acc =
    match getpwent () with
    | None -> endpwent () ; acc
    | Some pw -> loop (pw :: acc)
  in
  setpwent () ;
  loop [] |> List.rev

let write_db ?(file="/etc/passwd") db =
  (* let fd = open_shadow ~file () in *)
  (* List.iter (putspent fd) db; *)
  (* close_shadow fd *)
  ()

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
