;; A call to load-file that loads the current file from the buffer

(defun load-this-file ()
  (interactive)
  (load-file buffer-file-name))

(provide 'load-this-file)