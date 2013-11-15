open Unix

open OPasswd

let tmp_shadow_file = Unix.getcwd () ^ "/dummy-shadow"
let tmp_passwd_file = Unix.getcwd () ^ "/dummy-passwd"

let test_name = ref "root"

let chspwd_test name pass =
  let open Shadow in

  Printf.printf "Getting password for %s\n" name;

  let locked = lckpwdf () in
  Printf.printf "Lock acquired? %b\n" locked;
  if not locked
  then (print_endline "chspwd_test couldn't acquire shadow lock"; None)
  else
    match getspnam name with
    | None -> raise @@ Invalid_argument name
    | Some sp ->
       Printf.printf "Lock released? %b\n" (ulckpwdf ());

       Printf.printf "%s's passwd: %s\n" name sp.passwd;
       Printf.printf "%s's lstchg: %Ld\n" name sp.last_chg;
       Printf.printf "%s's min: %Ld\n" name sp.min;
       Printf.printf "%s's max: %Ld\n" name sp.max;
       Printf.printf "%s's flag: %d\n" name sp.flag;

       Printf.printf "setting %s's password to '%s'\n" name pass;
       let sp = { sp with passwd = pass } in

       Some sp

let create_file file =
  openfile file [ O_RDONLY; O_CREAT ] 0o666 |> close

let test_shadow () =
  create_file tmp_shadow_file;
  let name = !test_name in
  try
    Shadow.with_lock Shadow.(fun () ->
      match getspnam name with
      | None -> Printf.printf "Couldn't find user %s\n" name;
      | Some sp ->
         let db = get_db () in
         let db = update_db db { sp with passwd = "foobar" } in
         (* print_endline @@ String.concat "\n" @@ List.map to_string db; *)
         write_db ~file:tmp_shadow_file db)
  with _ ->
    print_endline "Couldn't acquire lock, must be root"

let test_passwd () =
  create_file tmp_passwd_file;
  let open Passwd in
  let name = !test_name in
  begin match getpwnam name with
  | None -> Printf.printf "test_passwd: Couldn't find user %s\n" name
  | Some pw ->
     let db = get_db () in
     let db = update_db db { pw with passwd = "barfoo" } in
     (* print_endline @@ String.concat "\n" @@ List.map to_string db; *)
     write_db ~file:tmp_passwd_file db;
  end;
  print_endline "* finished test_passwd"; flush Pervasives.stdout

let test_unshadow () =
  begin
    try
      let passwd = Common.unshadow () in
      print_endline passwd
    with _ ->
      print_endline "Couldn't acquire lock, must be root";
  end;
  print_endline "* finished test_unshadow"; flush Pervasives.stdout

(* Try to blow up GC *)
let test_gc () =
  let name = !test_name
  and iter = 1000000 in

  (* Lower GC heap sizes, set verbose *)
  (* Gc.set { (Gc.get ()) with *)
  (*   Gc.verbose = 0x3FF; *)
  (*   Gc.minor_heap_size = 1; *)
  (* }; *)

  Printf.printf "Testing Passwd.getpwnam on %d iterations\n" iter;
  Pervasives.(flush stdout);
  for i = 1 to iter do
    ignore (Passwd.getpwnam name)
  done;

  Printf.printf "Testing Shadow.getspnam on %d iterations\n" iter;
  begin
    try
      for i = 1 to iter do
        ignore Shadow.(with_lock (fun () -> getspnam name))
      done;
    with _ ->
      print_endline "Couldn't acquire lock, must be root";
  end;
  print_endline "* finished test_unshadow"; flush Pervasives.stdout

let test_chspwd name pass =
  let open Shadow in
  (match (chspwd_test "root" "foobar") with
  | None -> ()
  | Some sp ->
     Printf.printf "test_chspwd passwd? %b\n" (sp.passwd = "foobar"));
  print_endline "* finished test_chspwd"; flush Pervasives.stdout

let test_null_passwd name =
  match Passwd.getpwnam name with
  | None -> ()
  | Some pw ->
     Printf.printf "getting %s's gecos val\n" name;
     Printf.printf "  gecos: %s\n" pw.Passwd.gecos

let main =
  test_name := "postfix";
  test_chspwd !test_name "foobar";
  test_shadow ();
  test_passwd ();
  test_passwd ();
  test_unshadow ();
  test_null_passwd !test_name;
  test_gc ();
  ()

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
