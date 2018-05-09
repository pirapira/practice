(defthm subsetp-equal-cdr
  (IMPLIES
     (SUBSETP-EQUAL X (CDR Y))
     (SUBSETP-EQUAL X Y)))

(defthm subsetp-reflexive
  (subsetp x x))
