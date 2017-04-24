theory addu256

imports Main "~~/src/HOL/Word/Word" 

begin

(* https://github.com/axic/julia-wasm-arithmetics/blob/master/addu256.julia *)

definition split256 :: "256 word \<Rightarrow> (64 word \<times> 64 word \<times> 64 word \<times> 64 word)"
where
"split256 x =
    (let (x4 :: 64 word, x321 :: 192 word) = word_split x in
    (let (x3 :: 64 word, x21 :: 128 word) = word_split x321 in
    (let (x2 :: 64 word, x1 :: 64 word) = word_split x21 in
      (x1, x2, x3, x4))))"

definition combine256 :: "64 word \<Rightarrow> 64 word \<Rightarrow> 64 word \<Rightarrow> 64 word \<Rightarrow> 256 word"
where
"combine256 r1 r2 r3 r4 = word_cat r4 (word_cat r3 (word_cat r2 r1 :: 128 word) :: 192 word)"

definition booltou64 :: "bool \<Rightarrow> 64 word"
where
"booltou64 b = (if b then 1 else 0)"

definition addu256 :: "256 word \<Rightarrow> 256 word \<Rightarrow> (256 word \<times> bool)"
where
"addu256 x y =
  (let carry :: bool = False in
  (let (x1, x2, x3, x4) = split256 x in
  (let (y1, y2, y3, y4) = split256 y in

  (let r1 = x1 + y1 in
  (let carry = r1 < x1 in

  (let r2 = x2 + booltou64 carry in
  (let carry = r2 < x2 in

  (let r2 = r2 + y2 in
  (let carry = r2 < y2 \<or> carry in

  (let r3 = x3 + booltou64 carry in
  (let carry = r3 < x3 in

  (let r3 = r3 + y3 in
  (let carry = r3 < y3 \<or> carry in

  (let r4 = x4 + booltou64 carry in
  (let carry = r4 < x4 in

  (let r4 = r4 + y4 in

  (combine256 r1 r2 r3 r4, r4 < x4 \<or> carry)))))))))))))))))"

(* introduce the carry bit error, and see if nitpick can find it *)

value "split256 1"

definition example_x :: "256 word" where "example_x = 66666626266"
definition example_y :: "256 word" where "example_y = 9994999949993929"

value "fst (addu256 example_x example_y) = example_x + example_y"

theorem addu256correct :
  "fst (addu256 x y) = x + y"
apply(simp add: addu256_def)
apply(case_tac "split256 x"; simp)
apply(case_tac "split256 y"; simp)
oops

end
