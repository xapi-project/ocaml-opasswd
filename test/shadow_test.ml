open Shadow
open Unix

let tmp_shadow_file = "/home/mike/Projects/ocaml/ocaml-shadow/dummy-file"

let _ =
	print_endline "Getting password for dummy";

	Printf.printf "Lock acquired? %b\n" (lckpwdf ());
	let sp = getspnam "dummy" in
	Printf.printf "Lock released? %b\n" (ulckpwdf ());

	Printf.printf "dummy's passwd: %s\n" sp.pwd;
	Printf.printf "dummy's lstchg: %Ld\n" sp.last_chg;
	Printf.printf "dummy's min: %Ld\n" sp.min;
	Printf.printf "dummy's max: %Ld\n" sp.max;

	print_endline "setting dummy's password to 'foobar'";
	let sp = { sp with pwd = "foobar" } in

	let f = openfile tmp_shadow_file [O_WRONLY; O_CREAT; O_TRUNC] 0o666 in
	putspent sp f;
	close f;

	let f = open_in tmp_shadow_file in
	begin
		try
			let l = input_line f in
			print_endline "we wrote:";
			print_endline l
		with _ ->
			Printf.printf "Couldn't read file '%s'\n" tmp_shadow_file
	end;
	close_in f
