open Printf

type kstate = int array
	(* {
	sfrom: int;
	label: int;
	sto: int;
} *)

exception No_next of kstate

let compare_state s1 s2 = Pervasives.compare s1 s2

module Key = 
struct
	type t = kstate
	let compare = Pervasives.compare
end;;

module State_set = Set.Make(Key)

let state si ignore_label = if ignore_label then [|si|] else [|si;-1;si|] 
	
let str_kstate s = 
	let str = ref "(" in
	for i = 0 to Array.length s - 2 do
		str := !str ^ (string_of_int s.(i)) ^ ","
	done;
	!str ^ (string_of_int s.(Array.length s - 1)) ^ ")"


type t = {
	init: kstate;
	trans: (kstate, State_set.t) Hashtbl.t;
}

let create_model s = {init = state s false; trans = Hashtbl.create 1;} 


let add_trans ks s1 s2 = 
	try
		Hashtbl.replace ks.trans s1 (State_set.add s2 (Hashtbl.find ks.trans s1))
	with Not_found ->
		Hashtbl.add ks.trans s1 (State_set.singleton s2)

let next ks s ignore_label = 
	if ignore_label then begin
		let nexts = ref State_set.empty in
		let lts_trans = Bcg_interface.trans s.(0) in
		List.iter (fun (ln, lv, ns) -> 
			let next_state = [|ns|] in
			(* {sfrom = ns; label = -1; sto = ns;} in *)
			nexts := State_set.add next_state !nexts
			) lts_trans;
		!nexts
	end else begin
		if Hashtbl.mem ks.trans s then begin
			let nexts = Hashtbl.find ks.trans s in
			Hashtbl.remove ks.trans s;
			nexts
		end else begin
			let lts_trans = Bcg_interface.trans s.(0) in
			List.iter (fun (ln, lv, ns) -> 
				if lv then begin
					let label_state = [|s.(0);ln;ns|] 
					and next_state = [|ns;-1;ns|] in
					(* let label_state = {sfrom = s.sfrom; label = ln; sto = ns;} 
					and next_state = {sfrom = ns; label = -1; sto = ns;} in *)
					add_trans ks s label_state;
					add_trans ks label_state next_state
				end else begin
					let next_state = [|ns;-1;ns|] in
					add_trans ks s next_state
				end
				) lts_trans;
			try 
				let nexts = Hashtbl.find ks.trans s in
				Hashtbl.remove ks.trans s;
				nexts
			with Not_found -> 
				State_set.empty
		end
	end

let is_label s = Array.length s = 3 && s.(1) <> (-1)
let is_state s = not (is_label s)
(* type t = {
	kinit: state;
	ktrans: (state, state list) Hashtbl.t;
	(* klabels: () *)
}

let add_trans ks s1 s2 = 
	if Hashtbl.mem ks.ktrans s1 then
		Hashtbl.replace ks.ktrans s1 (s2::(Hashtbl.find ks.ktrans s1))
	else 
		Hashtbl.add ks.ktrans s1 [s2]

let next ks s1 = 
	try
		Hashtbl.find ks.ktrans s1
	with
	| _ -> [] *)



