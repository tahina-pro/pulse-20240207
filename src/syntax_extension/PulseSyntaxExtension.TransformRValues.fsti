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

module PulseSyntaxExtension.TransformRValues
module Sugar = PulseSyntaxExtension.Sugar
module Err = PulseSyntaxExtension.Err
module PulseEnv = PulseSyntaxExtension.Env
val transform (_:PulseEnv.env_t) (p:Sugar.stmt)
  : Err.err Sugar.stmt
