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

module Pulse.Lib.HigherArray
open Pulse.Main
open FStar.Tactics.V2
open Pulse.Lib.Core
open PulseCore.FractionalPermission
open FStar.Ghost
module SZ = FStar.SizeT
module Seq = FStar.Seq
open FStar.PCM
module Frac = Pulse.Lib.PCM.Fraction
module PM = Pulse.Lib.PCM.Map
open Pulse.Lib.PCM.Array
module PA = Pulse.Lib.PCM.Array

assume
val pcm_ref_null (#a:Type) (p:FStar.PCM.pcm a) : pcm_ref p

assume
val is_pcm_ref_null (#a:Type) (#p:FStar.PCM.pcm a) (r:pcm_ref p) : b:bool { b <==> r == pcm_ref_null p }

assume
val pts_to_not_null (#a:Type) (#p:FStar.PCM.pcm a) (r:pcm_ref p) (v:a)
: stt_ghost unit emp_inames (pcm_pts_to r v) (fun _ -> pcm_pts_to r v ** pure (not (is_pcm_ref_null r)))


/// An abstract type to represent a base array (whole allocation
/// unit), exposed for proof purposes only
[@@erasable]
let base_t (elt: Type u#a)
: Tot Type0
= Ghost.erased (base_len: SZ.t & pcm_ref (PA.pcm elt (SZ.v base_len)))

let base_len (#elt: Type) (b: base_t elt) : GTot nat = SZ.v (dfst b)

/// An abstract type to represent a C pointer, as a base and an offset
/// into its base
let l_pcm_ref (elt:Type u#a) (base_len:SZ.t) =
  r:pcm_ref (PA.pcm elt (SZ.v base_len)){ is_pcm_ref_null r = false || base_len = 0sz }

noeq
type ptr ([@@@strictly_positive]elt: Type u#a) : Type0 = {
  base_len: Ghost.erased SZ.t;
  base: l_pcm_ref elt base_len;
  offset: (offset: nat { offset <= SZ.v base_len });
}

let null_ptr (a:Type u#a)
: ptr a
= { base_len = 0sz; base = pcm_ref_null (PA.pcm a 0) ; offset = 0 }

let is_null_ptr (#elt: Type u#a) (p: ptr elt)
: Pure bool
  (requires True)
  (ensures (fun res -> res == true <==> p == null_ptr elt))
= is_pcm_ref_null p.base

let base (#elt: Type) (p: ptr elt)
: Tot (base_t elt)
= (| Ghost.reveal p.base_len, p.base |)

let offset (#elt: Type) (p: ptr elt)
: Ghost nat (requires True) (ensures (fun offset -> offset <= base_len (base p)))
= p.offset

let ptr_base_offset_inj (#elt: Type) (p1 p2: ptr elt) : Lemma
  (requires (
    base p1 == base p2 /\
    offset p1 == offset p2
  ))
  (ensures (
    p1 == p2
  ))
= ()

let base_len_null_ptr (elt: Type u#a)
: Lemma
  (base_len (base (null_ptr elt)) == 0)
  [SMTPat (base_len (base (null_ptr elt)))]
= ()

let array ([@@@strictly_positive] elt: Type u#1)
: Type0
= (p: ptr elt & (length: Ghost.erased nat {offset p + length <= base_len (base p)}))

let length (#elt: Type) (a: array elt) : GTot nat =
  dsnd a

let ptr_of
  (#elt: Type)
  (a: array elt)
: Tot (ptr elt)
= match a with 
  | (| p, _ |) -> p

let is_full_array (#elt: Type) (a: array elt) : Tot prop =
  length a == base_len (base (ptr_of a))

let null (#a: Type u#1) : array a
= (| null_ptr a, Ghost.hide 0 |)

let length_fits #elt a = ()

let valid_perm
  (len: nat)
  (offset: nat)
  (slice_len: nat)
  (p: perm)
: prop
= let open FStar.Real in
  ((offset + slice_len <= len /\ slice_len > 0) ==> (p.v <=. one))


let pts_to (#elt: Type u#1) (a: array elt) (#p: perm) (s: Seq.seq elt) : Tot vprop =
  pcm_pts_to (ptr_of a).base (mk_carrier (SZ.v (ptr_of a).base_len) (ptr_of a).offset s p) **
  pure (
    valid_perm (SZ.v (ptr_of a).base_len) (ptr_of a).offset (Seq.length s) p /\
    Seq.length s == length a
  )

let mk_array
    (#elt: Type u#1)
    (base_len: SZ.t)
    (base:l_pcm_ref elt base_len)
    (offset:nat { offset <= SZ.v base_len})
: array elt
= (| { base_len; base; offset}, Ghost.hide (SZ.v base_len - offset) |)

```pulse
ghost
fn fold_pts_to
    (#elt: Type u#1)
    (base_len: SZ.t)
    (base:l_pcm_ref elt base_len)
    (offset:nat { offset <= SZ.v base_len})
    (#p: perm { p `lesser_equal_perm` full_perm})
    (s: Seq.seq elt { Seq.length s == SZ.v base_len - offset})
requires
  pcm_pts_to base (mk_carrier (SZ.v base_len) offset s p)
ensures
  pts_to (mk_array base_len base offset) #p s
{
  let a = (mk_array base_len base offset);
  rewrite (pcm_pts_to base (mk_carrier (SZ.v base_len) offset s p))
      as pcm_pts_to (ptr_of a).base
            (mk_carrier (SZ.v (ptr_of a).base_len) 
                        (ptr_of a).offset
                        s p);
  fold (pts_to a #p s);
  rewrite (pts_to a #p s)
        as (pts_to (mk_array base_len base offset) #p s);
}
```


```pulse
ghost
fn pts_to_len'
  (#elt: Type u#1)
  (a:array elt)
  (#p:perm)
  (#x:Seq.seq elt)
requires pts_to a #p x
ensures pts_to a #p x ** pure (length a == Seq.length x)
{
  unfold pts_to a #p x;
  fold pts_to a #p x;
}
```
let pts_to_len = pts_to_len'

```pulse
fn alloc' 
    (#elt: Type u#1)
    (x: elt)
    (n: SZ.t)
requires emp
returns a:array elt
ensures 
  pts_to a (Seq.create (SZ.v n) x) **
  pure (length a == SZ.v n /\ is_full_array a)
{
  let v = (mk_carrier (SZ.v n) 0 (Seq.create (SZ.v n) x) full_perm);
  FStar.PCM.compatible_refl (PA.pcm elt (SZ.v n)) v;
  let b = Pulse.Lib.Core.alloc #_ #(PA.pcm elt (SZ.v n)) v;
  pts_to_not_null b _;
  fold_pts_to n b 0 #full_perm (Seq.create (SZ.v n) x);
  mk_array n b 0;
}
```
let alloc = alloc'

```pulse
fn read
    (#t: Type)
    (a: array t)
    (i: SZ.t)
    (#p: perm)
    (#s: Ghost.erased (Seq.seq t){SZ.v i < Seq.length s})
requires pts_to a #p s
returns res:t
ensures 
    pts_to a #p s **
    pure (res == Seq.index s (SZ.v i))
{
  unfold pts_to a #p s;
  with w. assert (pcm_pts_to (ptr_of a).base w);
  let v = Pulse.Lib.Core.read (ptr_of a).base w (fun _ -> w);
  fold (pts_to a #p s);
  fst (Some?.v (FStar.Map.sel v ((ptr_of a).offset + SZ.v i)));
}
```
let op_Array_Access = read

let mk_carrier_upd
  (#elt: Type)
  (len: nat)
  (offset: nat)
  (s: Seq.seq elt)
  (i: nat)
  (v: elt)
  (_: squash (
    offset + Seq.length s <= len /\
    i < Seq.length s
  ))
: Lemma
  (ensures (
    let o = mk_carrier len offset s full_perm in
    let o' = mk_carrier len offset (Seq.upd s i v) full_perm in
    o' `Map.equal` Map.upd o (offset + i) (Some (v, full_perm))
  ))
= ()

```pulse
fn write
    (#t: Type)
    (a: array t)
    (i: SZ.t)
    (v: t)
    (#s: Ghost.erased (Seq.seq t) {SZ.v i < Seq.length s})
requires pts_to a s
ensures pts_to a (Seq.upd s (SZ.v i) v)
{
  unfold pts_to a #full_perm s;
  with w. assert (pcm_pts_to (ptr_of a).base w);
  mk_carrier_upd (SZ.v (ptr_of a).base_len) ((ptr_of a).offset) s (SZ.v i) v ();
  Pulse.Lib.Core.write (ptr_of a).base w _
      (PM.lift_frame_preserving_upd
        _ _
        (Frac.mk_frame_preserving_upd
          (Seq.index s (SZ.v i))
          v
        )
        _ ((ptr_of a).offset + SZ.v i));
  fold (pts_to a #full_perm (Seq.upd s (SZ.v i) v));
}
```
let op_Array_Assignment = write

(*
let frame_preserving_upd_one (#elt:Type) (n:erased nat) (s:erased (Seq.seq elt) { Seq.length s == reveal n })
 : FStar.PCM.frame_preserving_upd (PA.pcm elt n)
      (mk_carrier n 0 s full_perm)
      (PA.one #elt #n)
= fun _ -> admit(); (PA.one #elt #n) 
 *)

```pulse
fn free'
    (#elt: Type)
    (a: array elt)
    (#s: Ghost.erased (Seq.seq elt))
requires
  pts_to a s **
  pure (is_full_array a)
ensures 
  emp
{
  unfold pts_to a #full_perm s;
  with w. assert (pcm_pts_to (ptr_of a).base w);
  // Pulse.Lib.Core.write (ptr_of a).base w (PA.one #elt #(length a)) (frame_preserving_upd_one #elt (length a) s);
  drop_ (pcm_pts_to (ptr_of a).base _)
}
```
let free = free'

let valid_sum_perm
  (len: nat)
  (offset: nat)
  (slice_len: nat)
  (p1 p2: perm)
: Tot prop
= let open FStar.Real in
  valid_perm len offset slice_len (sum_perm p1 p2)

```pulse
ghost
fn mk_carrier_share
  (#elt: Type u#1)
  (len: nat)
  (offset: nat)
  (s: Seq.seq elt)
  (p1 p2: perm)
  (_:squash (valid_sum_perm len offset (Seq.length s) p1 p2))
requires emp
ensures 
(
  // let c1 = (mk_carrier len offset s p1) in
  pure (
    composable (mk_carrier len offset s p1)
               (mk_carrier len offset s p2) /\
    mk_carrier len offset s (p1 `sum_perm` p2) 
      `Map.equal` 
    ((mk_carrier len offset s p1) `compose` (mk_carrier len offset s p2))
  )
)
  
{
  ()
}
```

```pulse
ghost
fn share'
  (#elt:Type)
  (arr:array elt)
  (#s:Ghost.erased (Seq.seq elt))
  (#p:perm)
requires pts_to arr #p s
ensures pts_to arr #(half_perm p) s ** pts_to arr #(half_perm p) s
{
  unfold pts_to arr #p s;
  with w. assert (pcm_pts_to (ptr_of arr).base w);
  mk_carrier_share (SZ.v (ptr_of arr).base_len)
       (ptr_of arr).offset
       s 
       (half_perm p) 
       (half_perm p) ();
  Pulse.Lib.Core.share (ptr_of arr).base
    (mk_carrier (SZ.v (ptr_of arr).base_len) (ptr_of arr).offset s (half_perm p))
    (mk_carrier (SZ.v (ptr_of arr).base_len) (ptr_of arr).offset s (half_perm p));
  fold pts_to arr #(half_perm p) s;
  fold pts_to arr #(half_perm p) s;
}
```
let share = share'

let mk_carrier_gather
  (#elt: Type)
  (len: nat)
  (offset: nat)
  (s1 s2: Seq.seq elt)
  (p1 p2: perm)
  (_:squash (
    let c1 = mk_carrier len offset s1 p1 in
    let c2 = mk_carrier len offset s2 p2 in
    composable c1 c2 /\
    Seq.length s1 == Seq.length s2 /\
    offset + Seq.length s1 <= len
  ))
: squash (
    let c1 = mk_carrier len offset s1 p1 in
    let c2 = mk_carrier len offset s2 p2 in
      composable c1 c2 /\
      mk_carrier len offset s1 (p1 `sum_perm` p2) == (c1 `compose` c2) /\
      mk_carrier len offset s2 (p1 `sum_perm` p2) == (c1 `compose` c2) /\
      s1 == s2
  )
=
  let c1 = mk_carrier len offset s1 p1 in
  let c2 = mk_carrier len offset s2 p2 in
  assert (composable c1 c2);
  assert (mk_carrier len offset s1 (p1 `sum_perm` p2) `Map.equal` (c1 `compose` c2));
  assert (mk_carrier len offset s2 (p1 `sum_perm` p2) `Map.equal` (c1 `compose` c2));
  mk_carrier_inj len offset s1 s2 (p1 `sum_perm` p2) (p1 `sum_perm` p2)


let mk_carrier_valid_sum_perm
  (#elt: Type)
  (len: nat)
  (offset: nat)
  (s: Seq.seq elt)
  (p1 p2: perm)
: squash
  (let c1 = mk_carrier len offset s p1 in
   let c2 = mk_carrier len offset s p2 in
   composable c1 c2 <==> valid_sum_perm len offset (Seq.length s) p1 p2)
= let c1 = mk_carrier len offset s p1 in
  let c2 = mk_carrier len offset s p2 in
  if Seq.length s > 0 && offset + Seq.length s <= len
  then
    let open FStar.Real in
    assert (Frac.composable (Map.sel c1 offset) (Map.sel c2 offset) <==> valid_perm len offset (Seq.length s) (sum_perm p1 p2))
  else ()

  ```pulse
  ghost
  fn of_squash (#p:prop) (s:squash p)
  requires emp
  ensures pure p
  {
    ()
  }
  ```

```pulse
ghost
fn gather'
  (#a:Type)
  (arr:array a)
  (#s0 #s1:Ghost.erased (Seq.seq a))
  (#p0 #p1:perm)
requires pts_to arr #p0 s0 ** pts_to arr #p1 s1
ensures pts_to arr #(sum_perm p0 p1) s0 ** pure (s0 == s1)
{
  unfold pts_to arr #p0 s0;
  with w0. assert (pcm_pts_to (ptr_of arr).base w0);
  unfold pts_to arr #p1 s1;
  with w1. assert (pcm_pts_to (ptr_of arr).base w1);
  Pulse.Lib.Core.gather (ptr_of arr).base w0 w1;
  of_squash (mk_carrier_gather (SZ.v (ptr_of arr).base_len) ((ptr_of arr).offset) s0 s1 p0 p1 ());
  of_squash (mk_carrier_valid_sum_perm (SZ.v (ptr_of arr).base_len) ((ptr_of arr).offset) s0 p0 p1);
  fold pts_to arr #(sum_perm p0 p1) s0;
}
```
let gather = gather'