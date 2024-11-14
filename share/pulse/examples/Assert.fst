(*
   Copyright ANONYMIZED

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

module Assert
#lang-pulse
open Pulse.Lib.Pervasives
module R = Pulse.Lib.Reference


fn test_assert (r0 r1: ref nat)
               (#p0 #p1:perm)
               (#v0:nat)
    requires 
        pts_to r0 #p0 v0 **
        (exists* v1. pts_to r1 #p1 v1)
    ensures
        pts_to r0 #p0 v0 **
        (exists* v1. pts_to r1 #p1 v1)
{
    //assert_ (pts_to r1 ?p1 ?v1); would be nice to have a version that also binds witnesses
    assert (R.pts_to r0 #p0 (v0 + 0));
    ()
}

