;;
;; Copyright 1996, MYDATA automation AB (Tom Bjorkholm  <tomb@mydata.se>)
;;
;; Some emacs lisp code to make editing merges in p4 easier.
;;
;; This is a dirty hack in emacs-lisp by someone (me) who do not 
;; know how to program in lisp. This can probably be done much
;; smarter.
;;



(define-key global-map "\C-c\C-c" 'p4-goto-next-conflict)
(define-key global-map "\C-c\C-n" 'p4-goto-next-conflict)
(define-key global-map "\C-c\C-b" 'p4-keep-base)
(define-key global-map "\C-c\C-y" 'p4-keep-yours)
(define-key global-map "\C-c\C-t" 'p4-keep-their)

;;
;;



(defvar p4-base-start  0 "The position of the start of the current base block")
(defvar p4-base-end    0 "The position of the end of the current base block" )
(defvar p4-yours-start 0 "The position of the start of the current your block")
(defvar p4-yours-end   0 "The position of the end of the current your block" )
(defvar p4-their-start 0 
  "The position of the start of the current their block")
(defvar p4-their-end   0 "The position of the end of the current their block" )

(defvar p4-cur-conflict-start 0 "The start position of the current conflict" )
(defvar p4-cur-conflict-end   0 "The end position of the current conflict" )

;;
;;

(defun p4-goto-next-conflict-mark()
  "Go to the next conflict mark in merge"
  (interactive)
  (search-forward-regexp 
   "<<<<<<<\\|=======\\|>>>>>>>\\||||||||" 10000000 t
   ))

(defun p4-goto-next-conflict()
  "Go to the next conflict in merge"
  (interactive)
  (search-forward "<<<<<<< "))


(load "paren")			;Enhanced parenthesis matching
(load "facemenu")

(defun p4-reload()
  "reload the p4_merge_mode.el -- just debug help"
  (interactive)
  (load-file "/usr/local/lib/p4_merge_mode.el"))


(defun p4-find-cur-conflict()
  "Find the current conflict and set variables for its position.
   Should be used before calling p4-find-blocks."
  (setq p4-cur-conflict-start 0)
  (setq p4-cur-conflict-end   0)
  (let ((p4-find-start (point)) 
	(p4-start1 0) 
	(p4-start2 100000)
	(p4-end1 -10000)
	(p4-end2 100000) )
    (if (search-backward "<<<<<<" 0 t )
	(setq p4-start1 (point)))
    (goto-char p4-find-start)
    (if (search-backward ">>>>>>" 0 t )
	(progn 
	  (end-of-line)
	  (setq p4-end1 (point))))
    (goto-char p4-find-start)
    (if (search-forward "<<<<<<" (+ p4-find-start  10000) t )
	(setq p4-start2 (point)))
    (goto-char p4-find-start)
    (if (search-forward ">>>>>>" (+ p4-find-start 10000) t )
	(progn 
	  (end-of-line)
	  (setq p4-end2 (point))))
    (goto-char p4-find-start)
    (if ( < (- p4-find-start p4-start1) (- p4-find-start  p4-end1))
	;; we have a start point with no end before p4-find-start
	(if (< (- p4-end2 p4-find-start) (- p4-start2 p4-find-start))
	    ;; we have an end point with no start after p4-find-start
	    ;; thus -- we are in a block
	    (progn
	      (setq p4-cur-conflict-start p4-start1)
	      (setq p4-cur-conflict-end   p4-end2))
	  ))
    (if (> (- p4-end2 p4-find-start) (- p4-start2 p4-find-start))
	;; we have an end point with a start after p4-find-start
	(if (< (- p4-start2 p4-find-start) (- p4-find-start  p4-end1))
	    ;; forward conflict closer that backward
	    (if (< (- p4-start2 p4-find-start) 400)
		;; less than about 5 lines to forward conflict
		;; -- we select the forward conflict
		(progn
		  (setq p4-cur-conflict-start p4-start2)
		  (setq p4-cur-conflict-end   p4-end2))
	      )))
    (goto-char p4-find-start)
    )
  )

(defun p4-find-single-block ( p4-start p4-end p4-text )
  "Find this single block name p4-text -- do not call from 
   outside p4-find-blocks"
  (goto-char p4-cur-conflict-start)
  (let ((p4-continue 1) (p4-may-start-here 0))
    (beginning-of-line)
    (while p4-continue
      (progn
	(if (p4-goto-next-conflict-mark)
	    (progn
	      (if (< p4-cur-conflict-end (point))
		  (setq p4-continue nil) ;; gone too far, bail out
		(progn  ;; else - everything is still OK
		  (if (looking-at " ")
		      (progn  ;; then-part
			(forward-char 1)
			(if (looking-at p4-text)
			    (progn ;; yes, found it
			      (beginning-of-line)
			      (set p4-start (point))
			      (end-of-line)
			      (p4-goto-next-conflict-mark)
			      (beginning-of-line)
			      (set p4-end (point))
			      (next-line 1)
			(beginning-of-line)
			(setq p4-continue nil)))))
		  (if (looking-at "
")
		      (progn ;; empty mark -- might start the right one
			(beginning-of-line)
			(setq p4-may-start-here (point))
			(end-of-line)
			(p4-goto-next-conflict-mark)
			(if (looking-at " ")
			    (progn 
			      (forward-char 1)
			      (if (looking-at p4-text)
				  (progn ;; yes, found it
				    (end-of-line)
				    (set p4-end (point))
				    (end-of-line)
				    (set p4-start p4-may-start-here)
				    (setq p4-continue nil)) ))
			  )))))
	      )
	  (setq p4-continue nil) ;; else clause -- no more conflict marks
	  )
	)))
)


(defun p4-find-blocks()
  "Find the current conflict blocks, and set variables
   to describe the each of the blocks yours, base and their.
   p4-find-cur-conflict must have been called to set start and 
   end of current conflict."
  (setq p4-base-start 0)
  (setq p4-base-end 0)
  (setq p4-yours-start 0)
  (setq p4-yours-end 0)
  (setq p4-their-start 0)
  (setq p4-their-end 0)
  (let ((p4-block-find-orig (point)))
    (p4-find-single-block 'p4-base-start 'p4-base-end "base")
    (p4-find-single-block 'p4-yours-start 'p4-yours-end "yours")
    (p4-find-single-block 'p4-their-start 'p4-their-end "their")
    (goto-char p4-block-find-orig)
    )
  )

(defun p4-keep-post()
  "Post part of p4-keep-..., use only from p4-keep-..."
    (goto-char p4-cur-conflict-start)
    (beginning-of-line)
    (p4-goto-next-conflict-mark)
    (backward-char 1)
    (if (< (point) p4-cur-conflict-end )
	(progn
	  (beginning-of-line)
	  (let ((p4-beg-line (point)))
	    (next-line 1)
	    (beginning-of-line)
	    (delete-region p4-beg-line (point)))
	  ))
    (p4-goto-next-conflict-mark)
    (backward-char 1)   
    (if (< (point) p4-cur-conflict-end )
	(progn
	  (beginning-of-line)
	  (let ((p4-beg-line (point)))
	    (next-line 1)
	    (beginning-of-line)
	    (delete-region p4-beg-line (point)))
	  ))
     )  

(defun p4-keep-base()
  "Keep the base version of this conflict"
  (interactive)
  (let ((p4-curpos (point)))
    (p4-find-cur-conflict)
    (p4-find-blocks)
    (if (and (not (eq 0 p4-yours-start)) (not (eq 0 p4-yours-end))) 
	(progn
	  (delete-region p4-yours-start p4-yours-end)
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-yours-end p4-yours-start)))
	  ))
    (p4-find-blocks)
    (if (and (not (eq 0 p4-their-start)) (not (eq 0 p4-their-end))) 
	(progn
	  (delete-region p4-their-start p4-their-end)    
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-their-end p4-their-start)))
	  ))
    (p4-keep-post)
    (goto-char p4-curpos)
    )
  (recenter)
  )

(defun p4-keep-yours()
  "Keep the yours version of this conflict"
  (interactive)
  (let ((p4-curpos (point)))
    (p4-find-cur-conflict)
    (p4-find-blocks)
    (if (and (not (eq 0 p4-base-start)) (not (eq 0 p4-base-end))) 
	(progn
	  (delete-region p4-base-start p4-base-end)
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-base-end p4-base-start)))
	  ))
    (p4-find-blocks)
    (if (and (not (eq 0 p4-their-start)) (not (eq 0 p4-their-end))) 
	(progn
	  (delete-region p4-their-start p4-their-end)    
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-their-end p4-their-start)))
	  ))
    (p4-keep-post)
    (goto-char p4-curpos)
    )
  (recenter)
  )

(defun p4-keep-their()
  "Keep the base version of this conflict"
  (interactive)
  (let ((p4-curpos (point)))
    (p4-find-cur-conflict)
    (p4-find-blocks)
    (if (and (not (eq 0 p4-yours-start)) (not (eq 0 p4-yours-end))) 
	(progn
	  (delete-region p4-yours-start p4-yours-end)
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-yours-end p4-yours-start)))
	  ))
    (p4-find-blocks)
    (if (and (not (eq 0 p4-base-start)) (not (eq 0 p4-base-end))) 
	(progn
	  (delete-region p4-base-start p4-base-end)    
	  (setq p4-cur-conflict-end 
		(- p4-cur-conflict-end (- p4-base-end p4-base-start)))
	  ))
    (p4-keep-post)
    (goto-char p4-curpos)
    )
  (recenter)
  )

(defun p4-mark-single-conflict()
  "Mark a single conflict, moving forward to conflict if necessary"
  (interactive)
  (if (p4-goto-next-conflict-mark)
      (progn ;; OK, there is a next conflict mark
	(p4-find-cur-conflict)
	(p4-find-blocks)
	(put-text-property p4-base-start p4-base-end 'face 
			   (facemenu-get-face (intern "fg:red")))
	(put-text-property p4-yours-start p4-yours-end 'face 
			   (facemenu-get-face (intern "fg:blue")))
	(put-text-property p4-their-start p4-their-end 'face 
			   (facemenu-get-face (intern "fg:darkgreen")))	
	(goto-char p4-cur-conflict-end)
	(end-of-line)
	t
	)
    ;; if test failed -- no next conflict mark
;;    (p4-goto-next-conflict-mark) ;; else part -- fail again to return nil
    nil
    )
  )

(defun p4-mark-conflicts()
  "Mark all conflicts"
  (interactive)
  (let ((p4-fsbeg (point)))
    (goto-char 0)
    (while (p4-mark-single-conflict) t)
    (goto-char p4-fsbeg)
    )
  (set-buffer-modified-p nil)
  )

(goto-char 0)
(p4-mark-conflicts)
