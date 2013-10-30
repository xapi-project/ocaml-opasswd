let shadow_file = "/etc/shadow"

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

type db = ent list

type file_descr = int64

external getspnam : string -> ent = "stub_getspnam"

external getspent : unit -> ent option = "stub_getspent"
external setspent : unit -> unit = "stub_setspent"
external endspent : unit -> unit = "stub_endspent"
external putspent : file_descr -> ent -> unit = "stub_putspent_fd"

external lckpwdf : unit -> bool = "stub_lckpwdf"
external ulckpwdf : unit -> bool = "stub_ulckpwdf"

external stub_fopen : string -> file_descr = "stub_fopen"
external stub_fclose : file_descr -> unit = "stub_fclose"

let open_shadow ?(file=shadow_file) () =
  (* try *)
    stub_fopen file
  (* with _ -> raise Unix.(Unix_error (EAGAIN, "open_shadow", file)) *)

let close_shadow fd =
  (* try *)
    stub_fclose fd
  (* with _ -> raise Unix.(Unix_error (EBADF, "close_shadow", "")) *)

let shadow_enabled () =
  try Unix.access shadow_file [Unix.F_OK]; true with _ -> false

let get_db () =
  let rec loop acc =
    match getspent () with
    | None -> endspent () ; acc
    | Some sp -> loop (sp :: acc)
  in
  setspent () ;
  loop [] |> List.rev

let rec update_db db ent =
  let rec loop acc = function
    | [] -> List.rev acc
    | e :: es when e.name = ent.name -> loop (ent::acc) es
    | e :: es -> loop (e::acc) es
  in loop [] db

let write_db ?(file=shadow_file) db =
  let fd = open_shadow ~file () in
  List.iter (putspent fd) db;
  close_shadow fd

let to_string p =
  let str i =
    if (Int64.compare i 0L) >= 0
    then Int64.to_string i
    else "" in
  Printf.sprintf "%s:%s:%s:%s:%s:%s:%s:%s:%s"
    p.name
    p.pwd
    (str p.last_chg)
    (str p.min)
    (str p.max)
    (str p.warn)
    (str p.inact)
    (str p.expire)
    (str p.flag)

let db_to_string db = db
  |> List.map to_string
  |> String.concat "\n"

let with_lock f =
  if lckpwdf ()
  then begin
    let ret = f () in
    ignore (ulckpwdf ());
    ret
  end
  else
    raise Unix.(Unix_error (EAGAIN, "with_lock", "Couldn't acquire shadow lock"))

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
