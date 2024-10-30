module PulseCore.IndirectionTheoryActions
module F = FStar.FunctionalExtensionality
module T = FStar.Tactics
module PM = PulseCore.MemoryAlt
module HST = PulseCore.HoareStateMonad
open PulseCore.IndirectionTheorySep
type action_kind =
| GHOST
| ATOMIC
| BUY
let maybe_ghost_action (k:action_kind) (m0 m1:mem) = GHOST? k ==> is_ghost_action m0 m1
let interpret (p:slprop) (m:mem) = interp p (core_of m)
let _ACTION 
  (a:Type u#a)
  (ak:action_kind)
  (except:inames)
  (expects:slprop)
  (provides: a -> GTot slprop)
  (frame:slprop)
= HST.st #full_mem a
    (requires fun m0 ->
        inames_ok except m0 /\
        interpret (expects `star` frame `star` mem_invariant except m0) m0 /\
        level_at_least_credits m0)
    (ensures fun m0 x m1 ->
        maybe_ghost_action ak m0 m1 /\
        inames_ok except m1 /\
        (not (BUY? ak) ==> level_decreases_by_spent_credits m0 m1) /\
        interpret (provides x `star` frame `star` mem_invariant except m1) m1 )

let _act_except 
    (a:Type u#a)
    (ak:action_kind)
    (except:inames)
    (expects:slprop)
    (provides: a -> GTot slprop)
 : Type u#(max a 4) 
 = frame:slprop -> _ACTION a ak except expects provides frame
let ghost_act a = _act_except a GHOST
let act a = _act_except a ATOMIC
let buy_act a = _act_except a BUY

val lift_mem_action #a #mg #ex #pre #post
                   (_:PM._pst_action_except a mg (lower_inames ex) pre post)
: _act_except a (if mg then GHOST else ATOMIC) ex (lift pre) (fun x -> lift (post x))


val later_elim (e:inames) (p:slprop) 
: ghost_act unit e (later p `star` later_credit 1) (fun _ -> p)

val buy (e:inames) (n:FStar.Ghost.erased nat)
: buy_act unit e emp (fun _ -> later_credit n)

val dup_inv (e:inames) (i:iref) (p:slprop)
: ghost_act unit e 
    (inv i p) 
    (fun _ -> inv i p `star` inv i p)

val new_invariant (e:inames) (p:slprop)
: ghost_act iref e p (fun i -> inv i p)

val with_invariant (#a:Type)
                   (#fp:slprop)
                   (#fp':a -> slprop)
                   (#opened_invariants:inames)
                   (#p:slprop)
                   (#ak:action_kind {not (BUY? ak)})
                   (i:iref{not (mem_inv opened_invariants i)})
                   (f:_act_except a ak
                        (add_inv opened_invariants i) 
                        (later p `star` fp)
                        (fun x -> later p `star` fp' x))
: _act_except a ak opened_invariants 
      (inv i p `star` fp)
      (fun x -> inv i p `star` fp' x)

val frame (#a:Type)
          (#ak:action_kind)
          (#opened_invariants:inames)
          (#pre:slprop)
          (#post:a -> slprop)
          (frame:slprop)
          ($f:_act_except a ak opened_invariants pre post)
: _act_except a ak opened_invariants (pre `star` frame) (fun x -> post x `star` frame)

open FStar.Ghost
module U = FStar.Universe
val witness_exists (#opened_invariants:_) (#a:_) (p:a -> slprop)
: ghost_act (erased a) opened_invariants
           (op_exists_Star p)
           (fun x -> p x)

val intro_exists (#opened_invariants:_) (#a:_) (p:a -> slprop) (x:erased a)
: ghost_act unit opened_invariants
  (p x)
  (fun _ -> op_exists_Star p)

val raise_exists (#opened_invariants:_) (#a:Type u#a) (p:a -> slprop)
: ghost_act unit opened_invariants
    (op_exists_Star p)
    (fun _a -> op_exists_Star #(U.raise_t u#a u#b a) (U.lift_dom u#a u#_ u#b p))

val elim_pure (#opened_invariants:_) (p:prop)
: ghost_act (u:unit{p}) opened_invariants (pure p) (fun _ -> emp)

val intro_pure (#opened_invariants:_) (p:prop) (_:squash p)
: ghost_act unit opened_invariants emp (fun _ -> pure p)

val drop (#opened_invariants:_) (p:slprop)
: ghost_act unit opened_invariants p (fun _ -> emp)

val lift_ghost
      (#a:Type)
      #opened_invariants #p #q
      (ni_a:PulseCore.HeapSig.non_info a)
      (f:erased (ghost_act a opened_invariants p q))
: ghost_act a opened_invariants p q