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

module Pulse.Typing.Metatheory

open Pulse.Syntax
open Pulse.Typing


let tot_typing_weakening_single #g #t #ty d x x_t =
  let g1 = singleton_env (fstar_env g) x x_t in
  let g' = mk_env (fstar_env g) in
  assert (equal (push_env g g') g);
  assert (equal (push_env (push_env g g1) g') (push_env g g1));
  assert (equal (push_env g g1) (push_binding g x ppname_default x_t));
  tot_typing_weakening g g' t ty d g1

let tot_typing_weakening_standard g #t #ty d g2 =
  let g1 = diff g2 g in
  let g' = mk_env (fstar_env g) in
  assert (equal (push_env g g1) g2);
  assert (equal (push_env g g') g);
  assert (equal (push_env (push_env g g1) g') g2);
  tot_typing_weakening g g' t ty d g1

let st_typing_weakening
  (g:env) (g':env { disjoint g g' })
  (t:st_term) (c:comp) (d:st_typing (push_env g g') t c)
  (g1:env { g1 `env_extends` g /\ disjoint g1 g' })
  : Dv (st_typing (push_env g1 g') t c) =

  let g2 = diff g1 g in
  let d = st_typing_weakening g g' t c d g2 in
  assert (equal (push_env (push_env g g2) g') (push_env g1 g'));
  d

let st_typing_weakening_standard
  (#g:env) (#t:st_term) (#c:comp) (d:st_typing g t c)
  (g1:env { g1 `env_extends` g })
  : Dv (st_typing g1 t c) =

  let g' = mk_env (fstar_env g) in
  assert (equal (push_env g g') g);
  let d = st_typing_weakening g g' t c d g1 in
  assert (equal (push_env g1 g') g1);
  d

let st_typing_weakening_end
  (g:env) (g':env { disjoint g g' })
  (t:st_term) (c:comp) (d:st_typing (push_env g g') t c)
  (g'':env { g'' `env_extends` g' /\ disjoint g'' g })
  : Dv (st_typing (push_env g g'') t c) =

  let g2 = diff g'' g' in
  let emp_env = mk_env (fstar_env g) in
  assert (equal (push_env g g')
                (push_env (push_env g g') emp_env));
  let d
    : st_typing (push_env (push_env (push_env g g') g2) emp_env) _ _
    = Pulse.Typing.Metatheory.Base.st_typing_weakening (push_env g g') emp_env t c (coerce_eq () d) g2 in
  assert (equal (push_env (push_env (push_env g g') g2) emp_env)
                (push_env (push_env g g') g2));
  push_env_assoc g g' g2;
  assert (equal (push_env (push_env g g') g2)
                (push_env g (push_env g' g2)));
  assert (equal (push_env g (push_env g' g2))
                (push_env g g''));
  coerce_eq () d

let veq_weakening
  (g:env) (g':env { disjoint g g' })
  (#v1 #v2:slprop) (d:slprop_equiv (push_env g g') v1 v2)
  (g1:env { g1 `env_extends` g /\ disjoint g1 g' })
  : slprop_equiv (push_env g1 g') v1 v2 =

  let g2 = diff g1 g in
  let d = Pulse.Typing.Metatheory.Base.veq_weakening g g' d g2 in
  assert (equal (push_env (push_env g g2) g') (push_env g1 g'));
  d

let veq_weakening_end g g' #v1 #v2 d g'' =
  let g2 = diff g'' g' in
  let emp_env = mk_env (fstar_env g) in
  assert (equal (push_env g g')
                (push_env (push_env g g') emp_env));
  let d = Pulse.Typing.Metatheory.Base.veq_weakening (push_env g g') emp_env #v1 #v2(coerce_eq () d) g2 in
  assert (equal (push_env (push_env (push_env g g') g2) emp_env)
                (push_env (push_env g g') g2));
  push_env_assoc g g' g2;
  assert (equal (push_env (push_env g g') g2)
                (push_env g (push_env g' g2)));
  assert (equal (push_env g (push_env g' g2))
                (push_env g g''));
  coerce_eq () d
