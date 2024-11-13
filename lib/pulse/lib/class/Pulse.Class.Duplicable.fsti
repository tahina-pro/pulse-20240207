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

module Pulse.Class.Duplicable

open Pulse.Lib.Core

[@@erasable]
class duplicable (p : slprop) = {
  dup_f : unit -> stt_ghost unit emp_inames p (fun _ -> p ** p);
}

let dup (p : slprop) {| d : duplicable p |} ()
  : stt_ghost unit emp_inames p (fun _ -> p ** p) = d.dup_f ()

instance val dup_inv (i : iname) (p : slprop) : duplicable (inv i p)
