    (defun rev (x)
      (if (endp x)
          nil
          (append (rev (cdr x)) (list (car x)))))

    (defun dupsp (x)  ; does x contain duplicate elements?
      (if (endp x)
          nil
          (if (member (car x) (cdr x))
              t
              (dupsp (cdr x)))))

(defthm member-equal-append
  (iff (MEMBER-EQUAL E (APPEND X Y))
       (OR (member-equal E X)
           (member-equal E Y))))

(defthm dupsp-append
  (equal
   (DUPSP (APPEND X (LIST E)))
   (DUPSP (CONS E X))))

(defthm member-equal-rev
  (iff
   (MEMBER-EQUAL E (REV X))
   (MEMBER-EQUAL E X)))


    (defthm dupsp-rev
      (equal (dupsp (rev x)) (dupsp x)))
