(require 'grep)
(require 'grep+)

(global-set-key [(control x) (g)] 'plain-grep)
(global-set-key [(control x) (control g)] 'flags-grep)
 
(defun plain-grep ()
  "grep the whole directory for something defaults to term at cursor position"
  (interactive)
  (cd my-project-dir)
  (setq default (thing-at-point 'symbol))
  (setq needle (or (read-string (concat "grep for <" default "> :"))))
  (setq needle (if (equal needle "") default needle))
  (grep (concat "find . -type f -print0 | xargs -0 -e grep.exe -nH --exclude=\"*cscope*\" -e \"" needle "\""))
)

(defun flags-grep ()
  "grep the whole directory for something defaults to term at cursor position"
  (interactive)
  (setq default (thing-at-point 'symbol))
  (setq needle (or (read-string (concat "grep for <" default "> :"))))
  (setq needle (if (equal needle "") default needle))
  (grep (concat "find . -type f -print0 | xargs -0 -e grep.exe -nH --exclude=\"*cscope*\" -e \"" needle "\""))
)

(provide 'my-grep)