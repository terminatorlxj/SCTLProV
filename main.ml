
open Term 
open Formula
open Modul
open Prover_output
open Prover
open Parser

let input_paras pl = 
	let l = List.length pl in
	let para_tbl = Hashtbl.create l in 
	let rec get_para_from_stdin i paras = 
		match paras with
		| (v, vt) :: paras' -> (match vt with
								| Int_type (i1, i2) -> Hashtbl.add para_tbl v (Const (int_of_string Sys.argv.(i)))
								| Bool_type -> Hashtbl.add para_tbl v (Const (let b = Sys.argv.(i) in (if b="true" then 1 else (if b="false" then (-1) else 0))))
								| _ -> print_endline ("invalid input for parameter: "^v^"."); exit 1); get_para_from_stdin (i+1) paras'
		| [] -> () in
	get_para_from_stdin 2 pl; para_tbl

let main () = 
	let arg_length = Array.length Sys.argv in
	if arg_length = 2 then 
	(
		let (modl_tbl, modl) = Parser.input Lexer.token (Lexing.from_channel (open_in Sys.argv.(1))) in
		let para_tbl = input_paras modl.parameter_list in
		let m = build_model modl modl_tbl para_tbl in
		print_endline ("verifying on the model "^(m.model_name)^"...");
		Prover.Seq_Prover.prove_model m 
	) else 
	(
		let (modl_tbl, modl) = Parser.input Lexer.token (Lexing.from_channel (open_in Sys.argv.(3))) in
		let para_tbl = input_paras modl.parameter_list in
		let m = build_model modl modl_tbl para_tbl in
		let out = open_out Sys.argv.(2) in
		print_endline ("verifying on the model "^(m.model_name)^"...");
		Prover_output.Seq_Prover.prove_model m out Sys.argv.(2);
		close_out out
	)
(*	let input_file = open_in Sys.argv.(1) in
 (try
	let lexbuf = Lexing.from_channel input_file in

		let (modl_tbl, modl) = Parser.input Lexer.token lexbuf in 
		let para_tbl = input_paras modl.parameter_list in
		let m = build_model modl modl_tbl para_tbl in
		(*(*print_endline (Model.to_string modl);*)
		(*Prover.Seq_Prover.prove_model (!Parser.modl)*)*)
		(*print_endline "parsing complete.";
		Hashtbl.iter (fun a b -> print_module b) modl_tbl;
		print_module (modl);
		print_model m;*)
		print_endline ("verifying on the model "^(m.model_name)^"...");
		Prover_output.Seq_Prover.prove_model m
		(*print_abs_model ()*) 

	with End_of_file -> print_endline "end of file"; exit 0) *)
let _ = 
	Printexc.print main ()
