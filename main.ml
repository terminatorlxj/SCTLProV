
open Term 
open Formula
open Modul
open Prover_output
open Prover
open Parser

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
			let modl_tbl1 = Hashtbl.create (Hashtbl.length modl_tbl) 
			and modl1 = modul021 modl in	
			Hashtbl.iter (fun a b -> Hashtbl.add modl_tbl1 a (modul021 b)) modl_tbl;
			let modl2 = modul122 modl1 (input_paras modl1.parameter_list) modl_tbl1 in
			let modl3 = modul223 modl2 in
			let modl4 = modul324 modl3 in
			let modl5 = modul425 modl4 in
			Prover.prove_model modl5
		with Parsing.Parse_error -> print_endline ("parse error at line: "^(string_of_int (!(Lexer.line_num))))
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

	)
let _ = 
	Printexc.print main ()
