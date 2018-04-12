theory RationalExample

imports Main Rat

begin

lemma "123.456 = -111.111 + 200 + 30 + 4 + 5/10 + 6/100 + (7/1000::rat)"
  by simp

end
