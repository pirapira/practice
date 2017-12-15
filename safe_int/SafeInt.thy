theory SafeInt

imports Main "~~/src/HOL/Word/Word" 

begin

(* signed 32 bit *)

type_synonym int32 = "32 word"

datatype safeInt32 = Invalid | Data "int32"

(* When does a safeInt32 represent an int *)
(* Note: int is the type of arbitrary precision integers. *)

fun represent :: "safeInt32 \<Rightarrow> int \<Rightarrow> bool"
  where
  "represent Invalid _ = True"
| "represent (Data d) i = (sint d = i)"

definition sadd_test :: "int32 \<Rightarrow> int32 \<Rightarrow> bool"
  where "sadd_test x y = ((x + y XOR x) AND (x + y XOR y) >> size x - 1 = 0)"

lemma sadd_test_sound :
  "sadd_test x y \<Longrightarrow> sint x + sint y = sint (x + y)"
  by(simp add: sadd_test_def  Word.sofl_test)

fun add :: "safeInt32 \<Rightarrow> safeInt32 \<Rightarrow> safeInt32"
  where
  "add Invalid _ = Invalid"
| "add _ Invalid = Invalid"
| "add (Data a) (Data b) =
     (if sadd_test a b then Data (a + b) else Invalid)"

lemma add_good :
  "represent a x \<Longrightarrow>
   represent b y \<Longrightarrow>
   represent (add a b) (x + y)"
  apply(cases a; auto)
  apply(cases b; auto)
  apply(rename_tac c d)
  by(simp add: sadd_test_sound)

end
