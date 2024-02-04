(*
   Copyright 2023 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

module Pulse.Checker.Return

open Pulse.Syntax
open Pulse.Typing
open Pulse.Checker.Pure
open Pulse.Checker.Base
open Pulse.Checker.Prover

module T = FStar.Tactics.V2
module P = Pulse.Syntax.Printer
module Metatheory = Pulse.Typing.Metatheory

let check_effect
    (#g:env) (#e:term) (#eff:T.tot_or_ghost) (#t:term)
    (d:typing g e eff t)
    (c:option ctag)
: T.Tac (c:ctag & e:term & typing g e (eff_of_ctag c) t)
= match c, eff with
  | None, T.E_Total -> 
    (| STT_Atomic, e, d |)
  | None, T.E_Ghost -> 
    (| STT_Ghost, e, d |)
  | Some STT_Ghost, T.E_Total ->
    (| STT_Atomic, e, d |)
  | Some STT_Ghost, T.E_Ghost -> 
    (| STT_Ghost, e, d |)
  | _, T.E_Total -> 
    (| STT_Atomic, e, d |)
  | _ -> 
    fail g (Some e.range) "Expected a total term, but this term has Ghost effect"
 

let check_tot_or_ghost_term (g:env) (e:term) (t:term) (c:option ctag)
: T.Tac (c:ctag & e:term & typing g e (eff_of_ctag c) t)
= let (| e, eff, d |) = check_term_at_type g e t in
  check_effect d c
  
noeq
type result_of_typing (g:env) =
  | R :
    c:ctag ->
    t:term ->
    u:universe ->
    ty:term ->
    universe_of g ty u ->
    typing g t (eff_of_ctag c) ty ->
    result_of_typing g

let compute_tot_or_ghost_term_type_and_u (g:env) (e:term) (c:option ctag)
: T.Tac (result_of_typing g)
= let (| t, eff, ty, (| u, ud |), d |) = compute_term_type_and_u g e in
  let (| c, e, d |) = check_effect d c in
  R c e u ty ud d
    
#push-options "--z3rlimit_factor 4"
let check_core
  (g:env)
  (ctxt:term)
  (ctxt_typing:tot_typing g ctxt tm_vprop)
  (post_hint:post_hint_opt g)
  (res_ppname:ppname)
  (st:st_term { Tm_Return? st.term })
  (ctag_ctxt:option ctag)
  : T.Tac (checker_result_t g ctxt post_hint) =
  
  let g = push_context "check_return" st.range g in
  let Tm_Return {insert_eq=use_eq; term=t} = st.term in
  let R c t u ty uty d : result_of_typing g =
    match post_hint with
    | None ->
      compute_tot_or_ghost_term_type_and_u g t ctag_ctxt
    | Some post ->
      let (| c, t, d |) = check_tot_or_ghost_term g t post.ret_ty ctag_ctxt in
      assert (g `env_extends` post.g);
      let ty_typing : universe_of post.g post.ret_ty post.u =
        post.ty_typing in
      let ty_typing : universe_of g post.ret_ty post.u =
        Metatheory.tot_typing_weakening_standard post.g post.ty_typing g in
      R c t post.u post.ret_ty ty_typing d
  in
  let x = fresh g in
  let px = res_ppname, x in
  let (| post_opened, post_typing |) : t:term & tot_typing (push_binding g x (fst px) ty)  t tm_vprop =
      match post_hint with
      | None -> 
        let (| t, ty |) = check_tot_term (push_binding g x (fst px) ty) tm_emp tm_vprop in
        (| t, ty |)
        
      | Some post ->
        // we already checked for the return type
        let post : post_hint_t = post in
        if x `Set.mem` (freevars post.post)
        then fail g None
               ("check_return: unexpected variable clash in return post,\
                 please file a bug report")
        else 
         let ty_rec = post_hint_typing g post x in
         (| open_term_nv post.post px, ty_rec.post_typing |)
  in
  assume (open_term (close_term post_opened x) x == post_opened);
  let post = close_term post_opened x in
  let d = T_Return g c use_eq u ty t post x uty d post_typing in
  let dd = (match_comp_res_with_post_hint d post_hint) in
  debug g (fun _ -> 
    let (| _, c, _ |) = dd in
    Printf.sprintf "Return comp is: %s"
      (Pulse.Syntax.Printer.comp_to_string c));
  prove_post_hint #g (try_frame_pre #g ctxt_typing dd res_ppname) post_hint t.range
#pop-options

let check
  (g:env)
  (ctxt:term)
  (ctxt_typing:tot_typing g ctxt tm_vprop)
  (post_hint:post_hint_opt g)
  (res_ppname:ppname)
  (st:st_term { Tm_Return? st.term })
  (check:check_t)
  : T.Tac (checker_result_t g ctxt post_hint)
  = let Tm_Return f = st.term in
    match Pulse.Checker.Base.is_stateful_application g f.term with
    | Some st_app ->
      check g ctxt ctxt_typing post_hint res_ppname st_app
    
    | None -> (
      match post_hint with
      | Some { ctag_hint } -> (
        check_core g ctxt ctxt_typing post_hint res_ppname st ctag_hint
        
      )
      | _ ->  check_core g ctxt ctxt_typing post_hint res_ppname st None
    )
