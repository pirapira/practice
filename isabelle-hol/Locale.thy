theory Locale

imports Main

begin

locale whatever =
  fixes re :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  assumes refl [simp]: "re x x"

begin

lemma my_lemma: "x = y \<Longrightarrow> re x y"
  by simp

end

print_locale! whatever
thm whatever_def

text "2.1. Targets: Extending Locales, I am not interested in this"

text "5.1. First Version: Replacement of Parameters Only"
text "Yes, I want to do this."

interpretation just_name: whatever "op \<le> :: int \<Rightarrow> int \<Rightarrow> bool"
  by unfold_locales auto

text "and where is my lemma?"

thm just_name.my_lemma

end