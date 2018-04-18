theory Matches

imports Main

begin

typedecl handlerResult
typedecl message

axiomatization clientIOHandler :: "nat \<Rightarrow> message \<Rightarrow> handlerResult"
axiomatization serverIOHandler :: "message \<Rightarrow> handlerResult"

datatype name = Client nat | Server

fun inputHandler :: "name \<Rightarrow> message \<Rightarrow> handlerResult"
  where
  "inputHandler (Client c) m = clientIOHandler c m"
| "inputHandler Server m = serverIOHandler m"

(*
  Matches.inputHandler.elims:
    inputHandler ?x ?xa = ?y \<Longrightarrow>
    (\<And>c m. ?x = Client c \<Longrightarrow> ?xa = m \<Longrightarrow> ?y = clientIOHandler c m \<Longrightarrow> ?P) \<Longrightarrow>
    (\<And>m. ?x = Server \<Longrightarrow> ?xa = m \<Longrightarrow> ?y = serverIOHandler m \<Longrightarrow> ?P) \<Longrightarrow> ?P
*)

end