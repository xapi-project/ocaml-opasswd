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

external lckpwdf : unit -> bool = "stub_lckpwdf"
external ulckpwdf : unit -> bool = "stub_ulckpwdf"

(* external stub_putspent_s : ent -> string -> unit = "stub_putspent_s" *)
(* external stub_putspent_f : ent -> Unix.file_descr -> unit = "stub_putspent_f" *)
external stub_putspent_fd : ent -> file_descr -> unit = "stub_putspent_fd"

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

let putspent fd e =
  stub_putspent_fd e fd

(* let putspent_f ?(file=shadow_file) e = *)
(*   let f = Unix.(openfile file [O_RDWR; O_TRUNC] 0) in *)
(*   stub_putspent_f e f; *)
(*   Unix.close f *)

(* let putspent_s ?(file=shadow_file) e = *)
(*   stub_putspent_s e file *)

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

let write_db ?(file="/etc/shadow") db =
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
