;;
;; Jeff's init.el file. loads all the stuff I need.
;;

;; Common lisp
(require 'cl)

;; load my elisp path

(add-to-list 'load-path "~/elisp")
(add-to-list 'load-path "~/elisp/cedet")
(add-to-list 'load-path "~/elisp/semantic")
(add-to-list 'load-path "~/elisp/eieio")
(add-to-list 'load-path "~/elisp/srecode")
(add-to-list 'load-path "~/elisp/speedbar")
(add-to-list 'load-path "~/elisp/ecb")
(add-to-list 'load-path "~/elisp/color-theme")
(add-to-list 'load-path "~/elisp/htmlfontify")
(add-to-list 'load-path "~/elisp/icicles")

(load-file "~/elisp/cedet/common/cedet.el")

;; default requires
;;(require 'icicles)
;;(icy-mode)
(require 'anything)
(require 'anything-config)
(require 'beyond-compare)
(require 'my-grep)
(require 'my-shell)
(require 'my-kill-buffer)
(require 'longlines)
(require 'load-this-file)
;;(require 'smart-tab)
(require 'folding)
(require 'my-save)
(require 'maxframe)
(add-hook 'window-setup-hook 'maximize-frame t)


(load "folding" 'nomessage 'noerror)
(folding-mode-add-find-file-hook)
(show-paren-mode t) ;;turn on paren matching, it is kinda nice all the time.
(setq-default cua-auto-tabify-rectangles nil)
(setq-default indent-tabs-mode nil)

;;(setq hfyview-quick-print-in-files-menu 't)
;;(require 'hfyview)
(require 'show-wspace)
(add-hook 'font-lock-mode-hook 'show-ws-highlight-tabs)
(add-hook 'font-lock-mode-hook 'show-ws-highlight-trailing-whitespace)

;; go-to-include file
(defun hoper-src(env) (let ((p (getenv env))) (if p (concat (file-name-as-directory p) "hoper/src") nil)))
(defun src-path () (list "." (hoper-src "LOCAL_BUILD") (hoper-src "GLOBAL_BUILD")))
(defun line-incl-fln(str) (when (string-match "^[[:space]*#[[:space]*include[[:space]+[\"\<]\\(.*\\)[\"\>][[:space]*$" str)
(match-string-no-properties 1 str)))
(defun incl-fln() (line-incl-fln (thing-at-point 'line)))
(defun open-incl-fln(str) (let ((fln (locate-file str (src-path)))) (find-file fln)))
(defun open-include-file()
"Open the C/C++ include file under cursor"
(interactive)
(let ((fln (incl-fln))) (when fln (open-incl-fln fln))))

(global-set-key [M-\kp-multiply] 'open-include-file)
(global-set-key [M-\kp-decimal] 'open-include-file)

;; go-to-definition-menu
(defun my-imenu-helper()
  (let (index-alist
    (result t)
      alist)
    ;; Create a list for this buffer only when needed.
    (while (eq result t)
      (setq index-alist (imenu--make-index-alist))
      (setq result (imenu--mouse-menu index-alist t))
      (and (equal result imenu--rescan-item)
        (imenu--cleanup)
        (setq result t imenu--index-alist nil)))
  result))

(defun my-imenu() (interactive) (imenu (my-imenu-helper)))
(global-set-key [?\M-\m] 'my-imenu)

;; paste menu
(global-set-key [(control c) (control v)] 'do-paste-menu)

(defun do-paste-menu()
"Show and paste from menu"
(interactive)
(let* ((y (x-popup-menu t 'yank-menu)) (z (car y)))
(when (and z (> (length z) 0))
(set-text-properties 0 (length z) nil z)
(insert z))))

;; my global set keys
(global-set-key '[(control x) (o)] 'other-window)
(global-set-key '[(control x) (\))] 'kmacro-end-or-call-macro)
(global-set-key '[(control x) (t)] 'beginning-of-buffer)
(global-set-key '[(control x) (e)] 'end-of-buffer)
(global-set-key '[(control tab)] 'tabbar-forward-tab)
(global-set-key '[(control meta tab)] 'tabbar-backward-tab)
(global-set-key '[(control x)(control tab)] 'tabbar-forward-group)
(global-set-key '[(control c) (control d)] 'cd)
(global-set-key '[(control c) (d)] 'cd)
(global-set-key '[(meta z)] 'zap-until-char)
(global-set-key "\C-r" 'query-replace)
(global-set-key [S-double-mouse-1] 'mark-symbol)
(global-set-key "\M-p" 'scroll-down)
(global-set-key "\M-n" 'scroll-up)
(global-set-key [(control up)] 'highlight-symbol-prev)
(global-set-key [(control down)] 'highlight-symbol-next)
(global-set-key [(control l)] 'highlight-symbol-at-point)
(global-set-key [(control *)] 'lazy-highlight-cleanup)
(global-set-key (kbd "C-;") 'comment-dwim)
(global-set-key [(tab)] 'smart-tab)
(global-set-key '[(meta o) (h)] 'hide-other)
(global-set-key '[(meta o) (s)] 'show-all)
(global-hl-line-mode 1)
(set-face-background 'hl-line "SlateGray4")
(auto-revert-mode t)

(defun match-paren (arg)
            "Go to the matching paren if on a paren; otherwise insert %."
            (interactive "p")
            (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
                  ((looking-at "\\s\)") (forward-char 1) (backward-list 1))))

(global-set-key '[(meta i)] 'match-paren)
(global-set-key '[(meta p)] 'highlight-symbol-prev)
(global-set-key '[(meta n)] 'highlight-symbol-next)

(defun smart-tab()
  "This smart tab is minibuffer compliant: it acts as usual in
   the minibuffer. Else, if mark is active, indents region. Else
   if point is at the end of a symbol, expands it. Else indents
   the current line."
   (interactive)
   (if (minibufferp)
     (unless (minibuffer-complete)
     (dabbrev-expand nil))
     (if mark-active
       (indent-region (region-beginning)
         (region-end))
       (if (looking-at "\\_>")
         (dabbrev-expand nil)
         (indent-for-tab-command)))))

(defun indent-or-complete ()
      "Complete if point is at end of a word, otherwise indent line."
      (interactive)
      (if (looking-at "\\>")
          (dabbrev-expand nil)
        (indent-for-tab-command)
        ))

;; my default setups
(require 'server)
(when (and (= emacs-major-version 23)
           (= emacs-minor-version 2)
           (equal window-system 'w32))
  (defun server-ensure-safe-dir (dir) "Noop" t)) ; Suppress error "directory
                                                 ; ~/.emacs.d/server is unsafe"
                                                 ; on windows.
(server-start)                                                              ;; start the server
(setq backup-directory-alist `(("." . "~/.saves")))                         ;; move all backups to a single directory
(setq auto-save-default nil)                                                ;; no auto save please
(fset 'yes-or-no-p 'y-or-n-p)                                               ;; stop forcing me to spell out "yes"
(setq ring-bell-function (lambda nil nil))                                  ;; no bells
(set-default-font "Lucida Console-10")                                      ;; change font
(transient-mark-mode t)                                                     ;; reqion highlighting
(setq icon-title-format "emacs [%b]")                                       ;; set window bar title
(setq frame-title-format '("Wheels emacs - %b" (buffer-file-name " @ %f"))) ;; set title bar
(column-number-mode t)                                                      ;; show column number
(setq inhibit-startup-message 't)                                           ;; no startup message
(setq inhibit-splash-screen t)                                              ;; no splash screen
(cua-mode t)                                                                ;; default to cut copy paste mode
(tool-bar-mode -1)                                                          ;; no tool bar

;; set color theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-dark-blue2)

;; symbol highlighting
(setq highlight-symbol-idle-delay 1.5)
(require 'highlight-symbol)
(require 'thingatpt)

;; Highlights a symbol
(defun mark-symbol ()
  (interactive)
  (if (get 'symbol 'thing-at-point)
      (funcall (get 'symbol 'thing-at-point))
    (let ((bounds (bounds-of-thing-at-point 'symbol)))
      (or bounds (error "No %s here" 'symbol))
   (goto-char (cdr bounds))
   (set-mark
    (save-excursion
      (goto-char (car bounds))
      (point))))))

(defun calc ()
  (interactive)
  (progn
    (shell-command "\"C:\\Program Files\\Microsoft Calculator Plus\\CalcPlus.exe\"&")
    (delete-other-windows)))

;; set how tabs act
(defun my-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
   (counter 1)
   (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
    (set (make-local-variable 'tab-stop-list) (nreverse ls))))
(my-build-tab-stop-list tab-width)

;; cedet
(require 'semantic)
(require 'semantic-ia)

;; turn on cscope semanticdb backend
(require 'semanticdb-cscope)
;;(semanticdb-enable-cscope-databases)

(require 'cedet)
(require 'cc-mode)
(global-semantic-idle-scheduler-mode 1)
(global-semanticdb-minor-mode 1)
(semanticdb-enable-gnu-global-databases 'c-mode)
(semanticdb-enable-gnu-global-databases 'c++-mode)
(global-ede-mode t)

(global-srecode-minor-mode 1)
(semantic-load-enable-excessive-code-helpers)

(require 'eassist)


(defun my-c-mode-common-hook ()
  (semanticdb-enable-cscope-in-buffer)
  (local-set-key "\C-." 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-cm" 'eassist-list-methods)
  (local-set-key "\C-cp" 'semantic-ia-fast-jump)
  (semantic-default-c-setup)
  (setq c-basic-offset 2)
  (setq semanticdb-find-default-throttle
        '(file local project unloaded system recursive))
  (c-set-offset 'case-label '+)
  (setq c-syntactic-indentation nil)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'topmost-intro 0)
  (c-toggle-syntactic-indentation 0)
  '(lambda()
     (let ((fbinds (where-is-internal 'forward-word))
      (bbinds (where-is-internal 'backward-word)))
       (while fbinds
    (define-key c-mode-common-map (car fbinds)
      'c-forward-subword)
    (setq fbinds (cdr fbinds)))
       (while bbinds
    (define-key c-mode-common-map (car bbinds)
      'c-backward-subword)
    (setq bbinds (cdr bbinds))))))


(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c++-mode-hook 'my-c-mode-common-hook)
(add-hook 'mode-line-hook 'my-c-mode-common-hook)

(require 'compile)
(defun my-compile-mode-hook()
  (next-error-follow-minor-mode t))
(add-hook 'compilation-mode-hook 'my-compile-mode-hook)

(setq auto-mode-alist
      (append '(("\\.cpp$" . c++-mode)
                ("\\.cpp\\'" . c++-mode)
                ("\\.inl$" . c++-mode)
                ("\\.h$" . c++-mode)
                ("\\.H$" . c++-mode)) auto-mode-alist))


;; tabbar stuff
;;(add-to-list 'load-path "~")
(require 'tabbar)
(tabbar-mode t)

(require 'ecb)
(global-set-key '[(control c) (control b)] 'ecb-toggle-ecb-windows)
(global-set-key '[(control c) (b)] 'ecb-toggle-ecb-windows)
(global-set-key '[(control c) (control r)] 'ecb-redraw-layout)
(global-set-key '[(control c) (r)] 'ecb-redraw-layout)

;; Zaps until character, but will not delete the given character
(defun zap-until-char (arg char)
  "Kill up to, but not including ARGth occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found."
  (interactive "p\ncZap until char: ")
  (if (char-table-p translation-table-for-input)
      (setq char (or (aref translation-table-for-input char) char)))
  (kill-region (point) (progn
          (search-forward (char-to-string char) nil nil arg)
          (goto-char (if (> arg 0) (1- (point)) (1+ (point))))
          (point))))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-auto-activate t)
 '(ecb-compilation-buffer-names (quote (("*cscope*") ("\\*[cC]ompilation.*\\*" . t) ("\\*i?grep.*\\*" . t) ("*Completions*") ("*Backtrace*") ("*Compile-log*"))))
 '(ecb-compile-window-height 15)
 '(ecb-compile-window-width (quote frame))
 '(ecb-layout-name "left6")
 '(ecb-layout-window-sizes (quote (("my-cscope-layout" (ecb-sources-buffer-name 0.2682926829268293 . 0.2911392405063291) (ecb-methods-buffer-name 0.2682926829268293 . 0.4177215189873418) (ecb-analyse-buffer-name 0.2682926829268293 . 0.27848101265822783)))))
 '(ecb-options-version "2.40")
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
 '(standard-indent 2)
 '(tab-width 2)
 '(truncate-lines t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; Disable buckets so that history buffer can display more entries
;;(setq ecb-history-make-buckets 'never)
(setq ecb-tip-of-the-day nil) ;; no tip of the day please
(setq global-semantic-stickyfunc-mode nil)
