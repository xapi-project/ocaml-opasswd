let get_password name =
  if Shadow.shadow_enabled ()
  then Shadow.(with_lock (fun () ->
    (getspnam name).pwd))
  else Passwd.((getpwnam name).passwd)

let put_password name cipher =
  if Shadow.shadow_enabled ()
  then Shadow.(with_lock (fun () ->
    let sp = getspnam name in
    if cipher <> sp.pwd
    then begin
      get_db ()
      |> fun db -> update_db db { sp with pwd = cipher }
      |> write_db
    end))
  else Passwd.(
    let pw = getpwnam name in
    if cipher <> pw.passwd
    then begin
      get_db ()
      |> fun db -> update_db db { pw with passwd = cipher }
      |> write_db
    end)

let unshadow () =
  if Shadow.shadow_enabled ()
  then begin
    let shadow_db = Shadow.(with_lock get_db)
    and passwd_db = Passwd.get_db () in
    List.map2
      (fun pw sp -> { pw with Passwd.passwd = sp.Shadow.pwd })
      passwd_db shadow_db
    |> Passwd.db_to_string
  end
  else Passwd.(get_db () |> db_to_string)

(* Local Variables: *)
(* indent-tabs-mode: nil *)
(* End: *)
