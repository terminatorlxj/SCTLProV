
open Term 
open Formula
open Modul
(*open Prover_output*)
open Prover
open Parser
(*
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
*)
let input_paras pl = 
	let rec get_para_from_stdin i paras = 
		match paras with
		| (v, vt) :: paras' -> (match vt with
								| Int_type (i1, i2) -> (Const (int_of_string Sys.argv.(i)))
								| Bool_type -> (Const (let b = Sys.argv.(i) in (if b="true" then 1 else (if b="false" then (-1) else 0))))
								| _ -> print_endline ("invalid input for parameter: "^v^"."); exit 1) :: (get_para_from_stdin (i+1) paras')
		| [] -> [] in
	get_para_from_stdin 2 pl

let main () = 
	let arg_length = Array.length Sys.argv in
	if arg_length = 2 then 
	begin
		try
		let (modl_tbl, modl) = Parser.input Lexer.token (Lexing.from_channel (open_in Sys.argv.(1))) in
		(*let stage_output0 = open_out (Sys.argv.(1) ^ "0") in
		Hashtbl.iter (fun a b -> output0 stage_output0 b false) modl_tbl;
		output0 stage_output0 modl true;
		flush stage_output0;
		close_out stage_output0;*)

		let modl_tbl1 = Hashtbl.create (Hashtbl.length modl_tbl) 
		and modl1 = modul021 modl in	
		Hashtbl.iter (fun a b -> Hashtbl.add modl_tbl1 a (modul021 b)) modl_tbl;
		(*let stage_output1 = open_out (Sys.argv.(1)^"1") in
		Hashtbl.iter (fun a b -> output1 stage_output1 b false) modl_tbl1;
		
		output1 stage_output1 modl1 true;
		flush stage_output1;
		close_out stage_output1;*)
		
		let modl2 = modul122 modl1 (input_paras modl1.parameter_list) modl_tbl1 in
		(*let stage_output2 = open_out (Sys.argv.(1)^"2") in		
		output2 stage_output2 modl2 "" true;
		flush stage_output2;
		close_out stage_output2;*)

		let modl3 = modul223 modl2 in
		(*let stage_output3 = open_out (Sys.argv.(1)^"3") in
		output3 stage_output3 modl3 "" true;
		flush stage_output3;
		close_out stage_output3;*)

		let modl4 = modul324 modl3 in
		(*let stage_output4 = open_out (Sys.argv.(1)^"4") in
		output4 stage_output4 modl4 "" true;
		flush stage_output4;
		close_out stage_output4;*)

		let modl5 = modul425 modl4 in
		(*let stage_output5 = open_out (Sys.argv.(1)^"5") in
		output5 stage_output5 modl5 "" true;
		flush stage_output5;
		close_out stage_output5;*)
		
		Prover.prove_model modl5
	
		with Parsing.Parse_error -> print_endline ("parse error at line: "^(string_of_int (!(Lexer.line_num))))
(*
		let para_tbl = input_paras modl.parameter_list in
		let m = build_model modl modl_tbl para_tbl in
		print_endline ("verifying on the model "^(m.model_name)^"...");
		Prover.Seq_Prover.prove_model m 
*)
	end else 
	(
		try
		let (modl_tbl, modl) = Parser.input Lexer.token (Lexing.from_channel (open_in Sys.argv.(3))) in

		let modl_tbl1 = Hashtbl.create (Hashtbl.length modl_tbl) 
		and modl1 = modul021 modl in	
		Hashtbl.iter (fun a b -> Hashtbl.add modl_tbl1 a (modul021 b)) modl_tbl;
		
		let modl2 = modul122 modl1 (input_paras modl1.parameter_list) modl_tbl1 in

		let modl3 = modul223 modl2 in

		let modl4 = modul324 modl3 in

		let modl5 = modul425 modl4 in
		let out = open_out Sys.argv.(2) in
		
		Prover_output.Seq_Prover.prove_model modl5 out Sys.argv.(2);
		close_out out
	
		with Parsing.Parse_error -> print_endline ("parse error at line: "^(string_of_int (!(Lexer.line_num))))

(*
		print_endline "output module not complete."

		let (modl_tbl, modl) = Parser.input Lexer.token (Lexing.from_channel (open_in Sys.argv.(3))) in
		let para_tbl = input_paras modl.parameter_list in
		let m = build_model modl modl_tbl para_tbl in
		let out = open_out Sys.argv.(2) in
		print_endline ("verifying on the model "^(m.model_name)^"...");
		Prover_output.Seq_Prover.prove_model m out Sys.argv.(2);
		close_out out
*)
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
