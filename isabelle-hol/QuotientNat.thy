theory QuotientNat

imports Main

begin

(* classify nats as even or odd to get something like a boolean *)

definition boolrel :: "nat \<Rightarrow> nat \<Rightarrow> bool"
  where
"boolrel x y \<equiv> even (x - y) \<and> even (y - x)"

lemma refl: "boolrel y y"
by(simp add: boolrel_def)

lemma boolrelI : "\<forall> z. boolrel x z = boolrel y z \<Longrightarrow> boolrel x = boolrel y"
  by(auto)

lemma ee: "even y \<Longrightarrow> even x \<Longrightarrow> boolrel x = boolrel y"
  apply(rule boolrelI)
  by(auto simp add: boolrel_def)

lemma oo: "odd y \<Longrightarrow> odd x \<Longrightarrow> boolrel x = boolrel y"
  apply(rule boolrelI)
  by(auto simp add: boolrel_def)

lemma trans: "boolrel x y \<Longrightarrow> boolrel x = boolrel y"
  by (smt Groups.add_ac(2) QuotientNat.refl add_diff_cancel_left' add_diff_inverse_nat boolrel_def
      ee oo order_le_less order_less_irrefl)

lemma eq: "equivp boolrel"
  by(auto simp add: equivp_def refl trans)

quotient_type new_type = "nat" / boolrel
  morphisms Rep Abs
  by(simp add: eq)

lemma "Abs 1 = Abs 3"
  by(simp add: new_type.abs_eq_iff boolrel_def)

end
