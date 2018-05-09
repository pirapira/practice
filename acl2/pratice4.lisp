(defun collect-once (x)
  (cond ((endp x) nil)
        ((member-equal (car x) (cdr x))
         (collect-once (cdr x)))
        (t (cons (car x) (collect-once (cdr x))))))

(defun dupsp (x)  ; does x contain duplicate elements?
  (if (endp x)
      nil
    (if (member (car x) (cdr x))
        t
      (dupsp (cdr x)))))

    (defthm main-theorem-1-about-collect-once
      (subsetp (collect-once x) x))

(defthm member-equal-collect-once
  (iff (MEMBER-EQUAL E
                       (COLLECT-ONCE X))
         (member-equal E X)))

    (defthm main-theorem-2-about-collect-once
      (not (dupsp (collect-once x))))

(defun while-loop-version (x a)
  (if (endp x) a
    (while-loop-version
     (cdr x)
     (if (member (car x) a) a
       (cons (car x) a)))))

; the second approach

(defthm subset-equal-cdr
  (IMPLIES
   (SUBSETP-EQUAL X (CDR Y))
   (SUBSETP-EQUAL X Y)))

(defthm subset-equal-refl
  (SUBSETP-EQUAL Y Y))

(defthm while-loop-cons
  (implies (consp x)
     (equal (while-loop-version x y)
            (while-loop-version (cdr x) (if (member (car x) y) y (cons (car x) y))))))

(defthm subseq-equalp-while-1
  (implies (subsetp-equal x z)
           (iff (SUBSETP-EQUAL (WHILE-LOOP-VERSION X Y) Z)
                (subsetp-equal y z))))

(defthm non-member
  (IMPLIES (AND (NOT (MEMBER-EQUAL E Z))
                (MEMBER-EQUAL E Y))
           (NOT (SUBSETP-EQUAL (WHILE-LOOP-VERSION X Y) Z))))

(defthm subset-equalp-while
  (iff
   (SUBSETP-EQUAL (WHILE-LOOP-VERSION X Y) Z)
   (and (subsetp-equal x z)
        (subsetp-equal y z))))

(defthm member-do-not-count
  (implies (member-equal e z)
           (iff
            (subsetp-equal (while-loop-version x (cons e y)) z)
            (subsetp-equal (while-loop-version x y) z))))

(defthm subsetp-equal-while-cons
  (IMPLIES (CONSP X)
    (IFF (SUBSETP-EQUAL (WHILE-LOOP-VERSION X Y) Z)
         (AND (MEMBER-EQUAL (CAR X) Z)
              (SUBSETP-EQUAL (WHILE-LOOP-VERSION (CDR X) Y) Z)))))

(defthm subset-first-general
  (subsetp (while-loop-version x y) (append x y)))

(defthm subset-first
  (subsetp (while-loop-version x nil) x))

;; frontier

(defthm uniq-first-gen
  (implies (not (dupsp y))
           (not (dupsp (while-loop-version x y)))))

(defthm uniq-first
  (not (dupsp (while-loop-version x nil))))
