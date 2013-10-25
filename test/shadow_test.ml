open Passwd
open Shadow
open Unix

let tmp_shadow_file = "/home/mike/Projects/ocaml/ocaml-shadow/dummy-file"

let chpwd_test name =
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

let main =
  let name = "backup" in
  with_lock (fun () ->
    let sp = getspnam name in
    let db = get_db () in
    let db = update_db db { sp with pwd = "foobar" } in
    write_db ~file:tmp_shadow_file db)

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
