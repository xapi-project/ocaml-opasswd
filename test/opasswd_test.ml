open Unix

open OPasswd

let tmp_shadow_file = Unix.getcwd () ^ "/dummy-shadow"
let tmp_passwd_file = Unix.getcwd () ^ "/dummy-passwd"

let chpwd_test name =
  let open Shadow in

  Printf.printf "Getting password for %s\n" name;

  Printf.printf "Lock acquired? %b\n" (lckpwdf ());
  let sp = getspnam name in
  Printf.printf "Lock released? %b\n" (ulckpwdf ());

  Printf.printf "%s's passwd: %s\n" name sp.pwd;
  Printf.printf "%s's lstchg: %Ld\n" name sp.last_chg;
  Printf.printf "%s's min: %Ld\n" name sp.min;
  Printf.printf "%s's max: %Ld\n" name sp.max;
  Printf.printf "%s's flag: %Ld\n" name sp.flag;

  Printf.printf "setting %s's password to 'foobar'\n" name;
  let sp = { sp with pwd = "foobar" } in

  let f = open_in tmp_shadow_file in
  begin
    try
      let l = input_line f in
      print_endline "we wrote:";
      print_endline l
    with _ ->
      Printf.printf "Couldn't read file '%s'\n" tmp_shadow_file
  end;
  close_in f;

  sp

let create_file file =
  try
    ignore (access file [ F_OK ])
  with _ ->
    openfile file [ O_CREAT ] 0o666 |> close

let main =
  (* Test Shadow *)
  create_file tmp_shadow_file;
  let name = "backup" in
  Shadow.with_lock Shadow.(fun () ->
    let sp = getspnam name in
    let db = get_db () in
    let db = update_db db { sp with pwd = "foobar" } in
    (* print_endline @@ String.concat "\n" @@ List.map to_string db; *)
    write_db ~file:tmp_shadow_file db);

  (* Test Passwd *)
  create_file tmp_passwd_file;
  let open Passwd in
  let pw = getpwnam name in
  let db = get_db () in
  let db = update_db db { pw with passwd = "barfoo" } in
  (* print_endline @@ String.concat "\n" @@ List.map to_string db; *)
  write_db ~file:tmp_passwd_file db

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
