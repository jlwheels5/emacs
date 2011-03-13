;; my killing of buffers
(global-set-key '[(control x) (control k)] 'my-kill-buffer)
(defun my-kill-buffer()
   (interactive)
   (if server-buffer-clients
      (server-done)
      (kill-buffer-and-window)))

(provide 'my-kill-buffer)