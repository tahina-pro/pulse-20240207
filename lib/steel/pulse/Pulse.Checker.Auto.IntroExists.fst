module Pulse.Checker.Auto.IntroExists

module RT = FStar.Reflection.Typing
module R = FStar.Reflection
module L = FStar.List.Tot
module T = FStar.Tactics
open FStar.List.Tot

open Pulse.Syntax
open Pulse.Checker.Pure
open Pulse.Checker.Common
open Pulse.Checker.VPropEquiv

open Pulse.Typing

module Metatheory = Pulse.Typing.Metatheory




let intro_exists =
  fun #g #ctxt p ->
  None
