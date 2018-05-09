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

; the first approach


(defun rev (x)
  (if (endp x)
      nil
    (append (rev (cdr x)) (list (car x)))))

(defthm append-assoc
  (equal
   (append (append x y) z)
   (append x (append y z))))

(defthm member-equal-append
  (iff
   (MEMBER-EQUAL e (APPEND x y))
   (or (member-equal e x)
       (member-equal e y))))

(defthm collect-once-append-elim
  (implies
   (member-equal (car x) y)
   (equal
    (COLLECT-ONCE (APPEND INIT
                          (CONS (CAR X) Y)))
    (COLLECT-ONCE (APPEND INIT Y)))))

(defthm equiv-gen
  (implies
   (and (true-listp y)
        (not (dupsp y)))
   (EQUAL (WHILE-LOOP-VERSION x y)
          (COLLECT-ONCE (APPEND (REV x) y)))))

(defthm equiv
  (equal (while-loop-version x nil)
         (collect-once (rev x))))

;;; and apply something

(defthm dupsp-collect-once
  (not (dupsp (collect-once x))))

(defthm subsetp-collect-once
  (subsetp (collect-once x) x))

(defthm subsetp-rev
  (subsetp (rev x) x))

(defthm dupsp-while
  (not (dupsp (while-loop-version x nil))))

(defthm subsetp-while
  (subsetp (while-loop-version x nil) x))
