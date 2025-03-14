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

module Pulse.Soundness.Common
module RT = FStar.Reflection.Typing
module R = FStar.Reflection.V2
module T = FStar.Tactics.V2
open FStar.List.Tot
open Pulse.Syntax
open Pulse.Reflection.Util
open Pulse.Typing
open Pulse.Elaborate

let ln_comp = c:comp_st { ln_c c }

let rec extend_env_l_lookup_fvar (g:R.env) (sg:env_bindings) (fv:R.fv) (us:R.universes)
  : Lemma 
    (ensures
      RT.lookup_fvar_uinst (extend_env_l g sg) fv us ==
      RT.lookup_fvar_uinst g fv us)
    [SMTPat (RT.lookup_fvar_uinst (extend_env_l g sg) fv us)]
  = match sg with
    | [] -> ()
    | hd::tl -> extend_env_l_lookup_fvar g tl fv us

// let rec extend_env_l_lookup_bvar (g:R.env) (sg:env_bindings) (x:var)
//   : Lemma 
//     (requires (forall x. RT.lookup_bvar g x == None))
//     (ensures (RT.lookup_bvar (extend_env_l g sg) x == elab_term_opt (lookup sg x)))
//     (decreases sg)
//     [SMTPat (RT.lookup_bvar (extend_env_l g sg) x)]
//   = match sg with
//     | [] -> ()
//     | hd :: tl -> extend_env_l_lookup_bvar g tl x

let lookup_elab_env (g:env) (x:var)
  : Lemma 
    (ensures (RT.lookup_bvar (elab_env g) x == lookup g x))
    [SMTPat (RT.lookup_bvar (elab_env g) x)]
  = admit ()  // TODO: FIX ME!!!!
  
let tot_typing_soundness (#g:env)
                         (#e:term)
                         (#t:term)
                         (d:tot_typing g e t)
  : GTot (RT.tot_typing (elab_env g) e t)
  = let E d = d in
    d

let ghost_typing_soundness (#g:env)
                           (#e:term)
                           (#t:term)
                           (d:ghost_typing g e t)
  : GTot (RT.ghost_typing (elab_env g) e t)
  = let E d = d in
    d

#push-options "--z3rlimit_factor 4"
let mk_t_abs_tot (g:env)
                 (#u:universe)
                 (#q:option qualifier)
                 (#ty:term)
                 (ppname:ppname)
                 (t_typing:tot_typing g ty (tm_type u))
                 (#body:term)
                 (#body_ty:term)
                 (#x:var { None? (lookup g x) /\ ~(x `Set.mem` freevars body) })
                 (body_typing:tot_typing (push_binding g x ppname ty) (open_term body x) body_ty)
  : GTot (RT.tot_typing (elab_env g)
            (mk_abs_with_name ppname.name ty (elab_qual q) body)
            (tm_arrow (mk_binder_ppname ty ppname) q (close_comp (C_Tot body_ty) x)))
  = let c = C_Tot body_ty in
    let r_body = open_term body x in
    let r_c = elab_comp c in
    let r_t_typing = tot_typing_soundness t_typing in
    let r_body_typing = tot_typing_soundness body_typing in
    RT.well_typed_terms_are_ln _ _ _ r_body_typing;
    RT.open_close_inverse r_body x;
    elab_comp_close_commute c x;      
    assert (~ (x `Set.mem` RT.freevars body));
    assume (~ (x `Set.mem` RT.freevars (RT.close_term r_body x)));
    RT.close_term_spec (elab_comp c) x;
    let r_t_typing : RT.tot_typing (elab_env g) ty (RT.tm_type u)
      = coerce_eq () r_t_typing //strange that this coercion is needed
    in
    let d : RT.tot_typing (elab_env g)
              (mk_abs_with_name ppname.name ty (elab_qual q)
                 (RT.close_term (open_term body x) x))
              (tm_arrow (mk_binder_ppname ty ppname) q (close_comp (C_Tot body_ty) x))
          = 
    RT.T_Abs (elab_env g)
             x
             ty
             (RT.close_term r_body x)
             (T.E_Total, r_c)
             u ppname.name (elab_qual q)
             _
             r_t_typing
             r_body_typing
    in
    elab_open_commute' body (null_var x) 0;
    RT.open_term_spec body x;
    let d : RT.typing _
                      (mk_abs_with_name ppname.name ty (elab_qual q)
                              (RT.close_term (RT.open_term body x) x))
                      _
          = d 
    in
    RT.close_open_inverse body x;
    d
#pop-options

let mk_t_abs (g:env)
             (#u:universe)
             (#ty:term)
             (#q:option qualifier)
             (#t_typing:typing g ty T.E_Total (tm_type u))
             (ppname:ppname)
             (r_t_typing:RT.tot_typing (elab_env g)
                                       ty
                                       (elab_comp (C_Tot (tm_type u))))
             (#body:st_term)
             (#x:var { None? (lookup g x) /\ ~(x `Set.mem` freevars_st body) })
             (#c:comp)
             (#body_typing:st_typing (push_binding g x ppname ty) (open_st_term body x) c)
             (r_body_typing:RT.tot_typing (elab_env (push_binding g x ppname ty))
                                          (elab_st_typing body_typing)
                                          (elab_comp c))
  : GTot (RT.tot_typing (elab_env g)
            (mk_abs_with_name ppname.name ty (elab_qual q) (RT.close_term (elab_st_typing body_typing) x))
            (tm_arrow (mk_binder_ppname ty ppname) q (close_comp c x)))
  = let r_body = elab_st_typing body_typing in
    let r_c = elab_comp c in
    RT.well_typed_terms_are_ln _ _ _ r_body_typing;
    RT.open_close_inverse r_body x;
    elab_comp_close_commute c x;      
    assume (~ (x `Set.mem` RT.freevars (RT.close_term r_body x)));
    RT.close_term_spec (elab_comp c) x;
    RT.T_Abs (elab_env g)
             x
             ty
             (RT.close_term r_body x)
             (T.E_Total, r_c)
             u ppname.name (elab_qual q)
             _
             r_t_typing
             r_body_typing

(*** Typing of combinators used
     in the elaboration **)


(** Type of bind **)

let bind_res (u2:R.universe) (t2 pre post2:R.term) =
  mk_stt_comp u2 t2 pre post2

let g_type_bind (u2:R.universe) (t1 t2 post1 post2:R.term) =
    mk_arrow (t1, R.Q_Explicit)
             (bind_res u2 t2 (R.mk_app post1 [bound_var 0 (* x *), R.Q_Explicit]) post2)

let bind_type_t1_t2_pre_post1_post2_f (u1 u2:R.universe) (t1 t2 pre post1 post2:R.term) =
  mk_arrow (g_type_bind u2 t1 t2 post1 post2, R.Q_Explicit)
           (bind_res u2 t2 pre post2)

let bind_type_t1_t2_pre_post1_post2 (u1 u2:R.universe) (t1 t2 pre post1 post2:R.term) =
  let f_type = mk_stt_comp u1 t1 pre post1 in
  mk_arrow (f_type, R.Q_Explicit)
           (bind_type_t1_t2_pre_post1_post2_f u1 u2 t1 t2 pre post1 post2)

let post2_type_bind t2 = mk_arrow (t2, R.Q_Explicit) slprop_tm
let bind_type_t1_t2_pre_post1 (u1 u2:R.universe) (t1 t2 pre post1:R.term) =
  let var = 0 in
  let post2 = mk_name var in
  mk_arrow (post2_type_bind t2, R.Q_Implicit)
           (RT.subst_term (bind_type_t1_t2_pre_post1_post2 u1 u2 t1 t2 pre post1 post2)
                          [ RT.ND var 0 ])

let post1_type_bind t1 = mk_arrow (t1, R.Q_Explicit) slprop_tm
let bind_type_t1_t2_pre (u1 u2:R.universe) (t1 t2 pre:R.term) =
  let var = 1 in
  let post1 = mk_name var in
  mk_arrow (post1_type_bind t1, R.Q_Implicit)
           (RT.subst_term (bind_type_t1_t2_pre_post1 u1 u2 t1 t2 pre post1)
                          [ RT.ND var 0 ])

let bind_type_t1_t2 (u1 u2:R.universe) (t1 t2:R.term) =
  let var = 2 in
  let pre = mk_name var in
  let pre_type = slprop_tm in
  mk_arrow (pre_type, R.Q_Implicit)
           (RT.subst_term (bind_type_t1_t2_pre u1 u2 t1 t2 pre)
                          [ RT.ND var 0 ])

let bind_type_t1 (u1 u2:R.universe) (t1:R.term) =
  let var = 3 in
  let t2 = mk_name var in
  let t2_type = RT.tm_type u2 in
  mk_arrow (t2_type, R.Q_Implicit)
           (RT.subst_term (bind_type_t1_t2 u1 u2 t1 t2)
                          [ RT.ND var 0 ])

let bind_type (u1 u2:R.universe) =
  let var = 4 in
  let t1 = mk_name var in
  let t1_type = RT.tm_type u1 in
  mk_arrow (t1_type, R.Q_Implicit)
           (RT.subst_term (bind_type_t1 u1 u2 t1)
                          [ RT.ND var 0 ])

(** Type of frame **)

let mk_star (l r:R.term) =
  let open R in
  let head = pack_ln (Tv_FVar (pack_fv star_lid)) in      
  R.mk_app head [(l, Q_Explicit); (r, Q_Explicit)]

let frame_res (u:R.universe) (t pre post frame:R.term) =
    mk_stt_comp u t
                  (mk_star pre frame)
                  (mk_abs t R.Q_Explicit (mk_star (R.mk_app post [bound_var 0, R.Q_Explicit]) frame))

let frame_type_t_pre_post_frame (u:R.universe) (t pre post frame:R.term) =
  let open R in
  let f_type = mk_stt_comp u t pre post in
  mk_arrow (f_type, Q_Explicit)
           (frame_res u t pre post frame)

let frame_type_t_pre_post (u:R.universe) (t pre post:R.term) =
  let var = 0 in
  let frame = mk_name var in
  mk_arrow (slprop_tm, R.Q_Explicit)
           (RT.close_term (frame_res u t pre post frame) var)

let frame_type_t_pre (u:R.universe) (t pre:R.term) =
  let var = 1 in
  let post = mk_name var in
  let post_type = mk_arrow (t, R.Q_Explicit) slprop_tm in
  mk_arrow (post_type, R.Q_Implicit)
           (RT.close_term (frame_type_t_pre_post u t pre post) var)

let frame_type_t (u:R.universe) (t:R.term) =
  let var = 2 in
  let pre = mk_name var in
  let pre_type = slprop_tm in
  mk_arrow (pre_type, R.Q_Implicit)
           (RT.close_term (frame_type_t_pre u t pre) var)

let frame_type (u:R.universe) =
  let var = 3 in
  let t = mk_name var in
  let t_type = RT.tm_type u in
  mk_arrow (t_type, R.Q_Implicit)
           (RT.close_term (frame_type_t u t) var)


(** Type of sub_stt **)

let stt_slprop_post_equiv_fv = R.pack_fv (mk_pulse_lib_core_lid "slprop_post_equiv")
let stt_slprop_post_equiv_univ_inst u = R.pack_ln (R.Tv_UInst stt_slprop_post_equiv_fv [u])
let stt_slprop_post_equiv (u:R.universe) (t t1 t2:R.term) = 
  R.mk_app (stt_slprop_post_equiv_univ_inst u) 
           [(t, R.Q_Implicit); (t1, R.Q_Explicit); (t2, R.Q_Explicit)]

let sub_stt_res u t pre post = mk_stt_comp u t pre post

let sub_stt_equiv_post u t pre1 post1 pre2 post2 = 
  mk_arrow (stt_slprop_post_equiv u t post1 post2, R.Q_Explicit)
           (sub_stt_res u t pre2 post2)

let sub_stt_equiv_pre u t pre1 post1 pre2 post2 = 
  mk_arrow (stt_slprop_equiv pre1 pre2, R.Q_Explicit)
           (sub_stt_equiv_post u t pre1 pre2 post1 post2)

let sub_stt_post2 u t pre1 post1 pre2 = 
  let var = 0 in
  let post2 = mk_name var in
  let post2_type = mk_arrow (t, R.Q_Explicit) slprop_tm in
  mk_arrow (post2_type, R.Q_Explicit)
           (RT.close_term (sub_stt_equiv_pre u t pre1 pre2 post1 post2) var)

let sub_stt_pre2 u t pre1 post1 = 
  let var = 1 in
  let pre2 = mk_name var in
  let pre2_type = slprop_tm in
  mk_arrow (pre2_type, R.Q_Explicit)
           (RT.close_term (sub_stt_post2 u t pre1 post1 pre2) var)

let sub_stt_post1 u t pre1 = 
  let var = 2 in
  let post1 = mk_name var in
  let post1_type = mk_arrow (t, R.Q_Explicit) slprop_tm in
  mk_arrow (post1_type, R.Q_Explicit)
           (RT.close_term (sub_stt_pre2 u t pre1 post1) var)

let sub_stt_pre1 u t = 
  let var = 3 in
  let pre1 = mk_name var in
  let pre1_type = slprop_tm in
  mk_arrow (pre1_type, R.Q_Explicit)
           (RT.close_term (sub_stt_post1 u t pre1) var)

let sub_stt_type u = 
  let var = 4 in
  let t = mk_name var in
  let ty_typ = RT.tm_type u in
  mk_arrow (ty_typ, R.Q_Explicit)
           (RT.close_term (sub_stt_pre1 u t) var)

(** Properties of environments suitable for elaboration **)

let has_stt_bindings (f:RT.fstar_top_env) =
    RT.lookup_fvar f RT.bool_fv == Some (RT.tm_type RT.u_zero) /\
    RT.lookup_fvar f slprop_fv == Some (RT.tm_type u2) /\ True
    //(forall (u1 u2:R.universe). RT.lookup_fvar_uinst f bind_fv [u1; u2] == Some (bind_type u1 u2)) /\
    //(forall (u:R.universe). RT.lookup_fvar_uinst f frame_fv [u] == Some (frame_type u)) /\
    //(forall (u:R.universe). RT.lookup_fvar_uinst f subsumption_fv [u] == Some (sub_stt_type u))        

let stt_env = e:env { has_stt_bindings (fstar_env e) }

let check_top_level_environment (f:RT.fstar_top_env)
  : option stt_env
  = admit(); Some (mk_env f) //we should implement this as a runtime check

let elab_comp_post (c:comp_st) : R.term =
  let t = comp_res c in
  let post = comp_post c in
  mk_abs t R.Q_Explicit post

let comp_post_type (c:comp_st) : R.term = 
  let t = comp_res c in
  mk_arrow (t, R.Q_Explicit) slprop_tm

assume
val inversion_of_stt_typing (g:env) (c:comp_st)
                            (#u:R.universe)
                            // _ |- stt u#u t pre (fun (x:t) -> post) : Type _ 
                            (_:RT.tot_typing (elab_env g) (elab_comp c) (RT.tm_type u))
  : GTot (x:( // _ |- t : Type u#u
          RT.tot_typing (elab_env g)
                        (comp_res c)
                        (RT.tm_type (comp_u c)) &
          // _ |- pre : slprop
          RT.tot_typing (elab_env g)
                        (comp_pre c)
                        tm_slprop &
          // _ |- (fun (x:t) -> post) : t -> slprop
          RT.tot_typing (elab_env g)
                        (elab_comp_post c)
                        (tm_arrow (null_binder (comp_res c)) None (C_Tot tm_slprop))){ u == universe_of_comp c })

let soundness_t (d:'a) = 
    g:stt_env ->
    t:st_term ->
    c:comp ->
    d':st_typing g t c{d' << d} ->
    GTot (RT.tot_typing (elab_env g)
                        (elab_st_typing d')
                        (elab_comp c))

let elab_open_commute' (e:term) (v:term) (n:index)
  : Lemma (ensures
             RT.subst_term e
                           [ RT.DT n v] ==
             (open_term' e v n))
          [SMTPat (open_term' e v n)] =

  elab_open_commute' e v n

let elab_close_commute' (e:term) (v:var) (n:index)
  : Lemma (RT.subst_term e [ RT.ND v n ] ==
           (close_term' e v n))
          [SMTPat (close_term' e v n)] =

  elab_close_commute' e v n

let elab_comp_close_commute (c:comp) (x:var)
  : Lemma (ensures elab_comp (close_comp c x) == RT.close_term (elab_comp c) x)
          [SMTPat (elab_comp (close_comp c x))] =

  elab_comp_close_commute c x

let elab_comp_open_commute (c:comp) (x:term)
  : Lemma (ensures elab_comp (open_comp_with c x) == RT.open_with (elab_comp c) x)
          [SMTPat (elab_comp (open_comp_with c x))] =

  elab_comp_open_commute c x
