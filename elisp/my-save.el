

(global-set-key '[(control x) (control s)] 'my-custom-save)

(defun my-custom-save ()
  (interactive)
  (replace-string "" "")
  (save-buffer))

(provide 'my-save)