;;; beyond-compare.el

;;; License:
;; This is free software

;;; Commentary:
;; Beyond Compare's Front end front end.
(defun bc-command (filename1 filename2)
  (start-process-shell-command "beyond-compare" nil
      (concat "\"c:/Program Files/Beyond Compare 3/BCompare.exe\" \"" filename1 "\"" " \""filename2 "\"")))

(defun get-filename-from-dired ()
  (save-excursion
       (beginning-of-buffer)
       (end-of-line)
       (backward-char)
       (buffer-substring-no-properties 3 (point))))

(defun bc-diff-files-or-folders (filename &optional wildcards)
  (interactive (find-file-read-args "Beyond Compare Buffer with: " t))
  (if (string= buffer-file-name nil)
      (setq my-filename (get-filename-from-dired))
      (setq my-filename buffer-file-name)
      (bc-command my-filename filename)))

(defun bc-diff-buffer-and-file (&optional buffer)
  "View the differences between BUFFER and its associated file.
This requires the external program `diff' to be in your `exec-path'."
  (interactive "bBuffer: ")
  (with-current-buffer (get-buffer (or buffer (current-buffer)))
    (if (and buffer-file-name
	     (file-exists-p buffer-file-name))
	(let ((tempfile (make-temp-file "buffer-content-")))
	  (unwind-protect
	      (progn
		(write-region nil nil tempfile nil 'nomessage)
		(bc-command buffer-file-name tempfile)
		(sit-for 0))))
      (message "Buffer %s has no associated file on disc" (buffer-name))
      ;; Display that message for 1 second so that user can read it
      ;; in the minibuffer.
      (sit-for 1)))
  ;; return always nil, so that save-buffers-kill-emacs will not move
  ;; over to the next unsaved buffer when calling `d'.
  nil)



; add key bind
(global-set-key "\C-cxd" 'bc-diff-files-or-folders)
(global-set-key "\C-cxf" 'bc-diff-buffer-and-file)

(provide 'beyond-compare)

;;; beyond-compare.el ends here.
