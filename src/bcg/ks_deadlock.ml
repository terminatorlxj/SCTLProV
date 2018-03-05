open Printf

type kstate = int

exception No_next of kstate

let compare_state s1 s2 = Pervasives.compare s1 s2

module Key = 
struct
	type t = kstate
	let compare = Pervasives.compare
end;;

module State_set = Set.Make(Key)

let deadlock_set = ref State_set.empty

let state si ignore_label = si

let str_kstate s = sprintf "{%d}" s

type t = {
	init: kstate;
	trans: (kstate, State_set.t) Hashtbl.t;
}

let create_model s = {init = s; trans = Hashtbl.create 1;} 

(* let trans = (kstate, kstate list) Hashtbl.t; *)

let add_trans ks s1 s2 = 
	try
		Hashtbl.replace ks.trans s1 (State_set.add s2 (Hashtbl.find ks.trans s1))
	with Not_found ->
		Hashtbl.add ks.trans s1 (State_set.singleton s2)

(* let next ks s = 
	if Hashtbl.mem ks.trans s then begin
		let nexts = Hashtbl.find ks.trans s in
		nexts
	end else begin
		let lts_trans = Bcg_interface.trans s in
		List.iter (fun (ln, ls, ns) -> 
			if ls<>"i" then begin
				let next_state = ns in
				add_trans ks s next_state
			end else begin
				let next_state = ns in
				add_trans ks s next_state
			end
			) lts_trans;
		try 
			let nexts = Hashtbl.find ks.trans s in
			nexts
		with Not_found -> 
			State_set.empty
	end *)

let next ks s ignore_label = 
	let lts_trans = Bcg_interface.trans s in
	let nexts = ref State_set.empty in
	if lts_trans = [] then
		deadlock_set := State_set.add s !deadlock_set;
	List.iter (fun (ln, lv, ns) -> 
		begin
			(* let next_state = ns in *)
			(* add_trans ks s next_state *)
			nexts := State_set.add ns !nexts
		end
		) lts_trans;
	!nexts

let is_state s = true
let is_label s = not (is_state s)

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



