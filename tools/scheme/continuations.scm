; let's say we have this expression
(display (+ 3 2))

; and we're evaluating (+ 3 2)
; then continuation is a function of what to do with the result of current expression to continue computation
; in this case continuation is (lambda (c) (display c))

; k is the continuation of the enclosing call/cc expression
(display (call/cc (lambda (k) (k "hello"))))

; essentially it's the same as replacing entire call/cc with the argument to k: (display "hello")
; scheme has no `return` keyword, but we can implement it using continuations
(define (block-with-return)
  (call/cc (lambda (return)
    (display "\nfirst\n")
    (display "second\n")
    ; continuation is (lambda (c) c)
    (return 99)
    (display "third\n"))))

; result is 99
(display (block-with-return))
(newline)

; things become interesting, when you start treating continuations as first-class object
; e.g saving it in a variable
(define (block-with-save log adder)
    (display "starting block-with-save\n")
    (call/cc (lambda (k) (set! *block-with-save* k)))
    (display log)
    (newline)
    (+ 8 adder))


; 17 as expected
(display (block-with-save "after call/cc" 9))
(newline)

; we executed block-with-save as usual, but now we can jump to it!
; same as replacing corresponding call/cc with 32, 32 is ignored, but (display log) & (+ 8 adder)
; are executed once again!
; it's like goto to the program state!
(*block-with-save* 32)

; call/cc is powerful, e.g. we can implement generators/coroutines with it:
(define (make-generator)
    (let ((gen 0))
        (call/cc (lambda next)
        gen))


(let ((gen (make-generator)))
    (display (gen))
    (newline)
    (display (gen))
    (newline))



