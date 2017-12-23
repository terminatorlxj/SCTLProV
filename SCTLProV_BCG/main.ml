

let main () = 
  let property = ref "deadlock" in
  (* let deadlock_prop = EU (SVar "x", SVar "y", Top, Bottom, SVar "ini")  *)
  (* and livelock_prop = EG (SVar "x", Atomic ("is_state", [SVar "x"]), SVar "ini") in *)
  (* and livelock_prop = EU (SVar "z", SVar "w", Top, EG (SVar "x", Atomic ("is_state", [SVar "x"]), SVar "w"), SVar "ini") in *)
  Arg.parse
    [
      "-deadlock", Arg.Unit (fun () -> property := "deadlock"), " Detect deadlock";
      "-livelock", Arg.Unit (fun () -> property := "livelock"), " Detect livelock";
    ]
    (fun s -> 
      let lstate = Bcg_interface.read_bcg s in
      (* let kstate = state lstate (!property = "deadlock") in
      let ks = create_model kstate in *)
      if !property = "deadlock" then
        Prover_deadlock.prove_model (Ks_deadlock.create_model lstate) [(!property, Formula_deadlock.EU (Formula_deadlock.SVar "x", Formula_deadlock.SVar "y", Formula_deadlock.Top, Formula_deadlock.Bottom, Formula_deadlock.SVar "ini"))] true true
      else 
        Prover_livelock.prove_model (Ks_livelock.create_model lstate) [(!property, Formula_livelock.EU (Formula_livelock.SVar "z", Formula_livelock.SVar "w", Formula_livelock.Top, Formula_livelock.EG (Formula_livelock.SVar "x", Formula_livelock.Atomic ("has_tau", [Formula_livelock.SVar "x"]), Formula_livelock.SVar "w"), Formula_livelock.SVar "ini"))] false false
    )
    "Usage: sctlbcg [<-deadlock>/<-livelock>] <filename>"

let _ = 
  Printexc.print main ()