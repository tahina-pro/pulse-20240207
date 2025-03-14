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

module Pulse.Typing.Util

open FStar.Tactics.V2

(* Like T.check_equiv, but will make sure to not delay any VC. *)
val check_equiv_now (g:env) (t1 t2 : term)
  : Tac (option (equiv_token g t1 t2) & issues)

(* As above, but disallowing SMT (and unfolding). This is supposed
to be a rather fast, unification-only check. *)
val check_equiv_now_nosmt (g:env) (t1 t2 : term)
  : Tac (option (equiv_token g t1 t2) & issues)

(* As above, but allowing unfolding. *)
val check_equiv_now_nosmt_unfold (g:env) (t1 t2 : term)
  : Tac (option (equiv_token g t1 t2) & issues)

(* Like T.universe_of, but will make sure to not delay any VC. *)
val universe_of_now : g:env -> e:term ->
  Tac (option (u:universe{typing_token g e (E_Total, pack_ln (Reflection.V2.Tv_Type u))}) & issues)
