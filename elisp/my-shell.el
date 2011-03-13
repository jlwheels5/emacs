;; This is my shell stuff

;; For subprocesses invoked via the shell
;; (e.g., "shell -c command")
(setq explicit-shell-file-name "bash.exe")
(setq shell-file-name explicit-shell-file-name)

(add-hook 'shell-mode-hook 'n-shell-mode-hook)
(defun n-shell-mode-hook ()
 "12Jan2002 - sailor, shell mode customizations."
 (local-set-key '[up] 'comint-previous-input)
 (local-set-key '[down] 'comint-next-input)
 (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)
 (setq comint-input-sender 'n-shell-simple-send)
 )
 
(defun n-shell-simple-send (proc command)
 "17Jan02 - sailor. Various commands pre-processing before sending to shell."
 (cond
  ;; Checking for clear command and execute it.
  ((string-match "^[ \t]*clear[ \t]*$" command)
   (comint-send-string proc "\n")
   (erase-buffer)
   )
  ;; Checking for man command and execute it.
  ((string-match "^[ \t]*man[ \t]*" command)
   (comint-send-string proc "\n")
   (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command))
   (setq command (replace-regexp-in-string "[ \t]+$" "" command))
   ;;(message (format "command %s command" command))
   (funcall 'man command)
   )
  ;; Send other commands to the default handler.
  (t (comint-simple-send proc command))
  )
 )

(add-hook 'comint-output-filter-functions
    'shell-strip-ctrl-m nil t)
(add-hook 'comint-output-filter-functions
    'comint-watch-for-password-prompt nil t)

(provide 'my-shell)
;; end of my-shell
 

