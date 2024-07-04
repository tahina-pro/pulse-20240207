module Pulse.Lib.ConditionVar
open Pulse.Lib.Pervasives
open Pulse.Lib.ConditionVarWithCodes
module CV = Pulse.Lib.ConditionVarWithCodes
////////////////////////////////////////////////////////////////
//Using condition vars directly with slprop1 slprops
////////////////////////////////////////////////////////////////

let code : CV.code = {
  t = slprop1_base;
  emp = down1 emp;
  up = (fun x -> up1_is_slprop1 x; up1 x);
  laws = ()
}

let code_of (p:slprop1) : CV.codeable code p = {
  c = down1 p;
  laws = ()
}

let cvar_t = CV.cvar_t code

let inv_name (c:cvar_t) = CV.inv_name c

let send (cv:cvar_t) (p:slprop) : slprop = CV.send cv p

let recv (cv:cvar_t) (p:slprop) : slprop = CV.recv cv p

let create (p:slprop1)
: stt cvar_t emp (fun b -> send b p ** recv b p)
= CV.create p (code_of p)

let signal (cv:cvar_t) (#p:slprop)
: stt unit (send cv p ** p) (fun _ -> emp)
= CV.signal cv #p

let wait (cv:cvar_t) (#p:slprop)
: stt unit (recv cv p) (fun _ -> p)
= CV.wait cv #p

let split (cv:cvar_t) (#p #q:slprop1)
: stt_ghost unit (add_inv emp_inames (inv_name cv))
  (recv cv (p ** q)) (fun _ -> recv cv p ** recv cv q)
= CV.split cv #p #q (code_of p) (code_of q)
