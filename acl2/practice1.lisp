(defun rev (x)
      (if (endp x)
          nil
        (append (rev (cdr x)) (list (car x)))))

(defun straight (x)
  (if (endp x)
      nil
    (cons (car x) (straight (cdr x)))))

(defthm double-rev
  (equal (rev (rev x)) (straight x)))

; here, I don't know what happened, but it finishes.

(defthm triple-rev
      (equal (rev (rev (rev x))) (rev x)))
