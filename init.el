
(message "Start reading ~/.emacs.d/init.el ...")

;; --------------------------------------------------------------------------------------------
;; SOME INIT ACTIONS
;; --------------------------------------------------------------------------------------------


;; Set startup screen photo
;; (setq fancy-splash-image "path")

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

;; Do not use `init.el` for `custom-*` code (generated by 'M-x customize' menu) - use `custom-file.el`.
(setq custom-file "~/.emacs.d/custom-file.el")

;; Use default Emacs bookmarks localisation (for now)
(setq bookmark-default-file "~/.emacs.d/bookmarks")

;; Assuming that the code in custom-file is execute before the code
;; ahead of this line is not a safe assumption. So load this file
;; proactively.
(load-file custom-file)

;; Load custom Emacs Lisp files (libs, functions, etc.)
(add-to-list 'load-path "~/.emacs.d/custom/")
(require 'custom-functions)

;; --------------------------------------------------------------------------------------------
;; SETUP PROXY SERVICES
;; --------------------------------------------------------------------------------------------
(setq url-proxy-services
   '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
     ("http" . "10.158.100.2:8080")
     ("https" . "10.158.100.2:8080")))

(setq url-proxy-services nil)

;; --------------------------------------------------------------------------------------------
;; SETUP PACKAGE REPOSITORIES
;; --------------------------------------------------------------------------------------------

(require 'package)

(add-to-list 'package-archives '("gnu"          . "https://elpa.gnu.org/packages/")     t)
(add-to-list 'package-archives '("melpa"        . "https://melpa.org/packages/")        t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Load Emacs Lisp packages, and activate them - variable ‘package-load-list’ controls which packages to load.
(package-initialize)

;; Update list of available packages - sth like 'git fetch'
;; doing it together with 'unless' reduces emacs startup time significantly
(unless package-archive-contents
  (package-refresh-contents))

(when (not (package-installed-p 'use-package))
        (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; --------------------------------------------------------------------------------------------
;; THEME
;; --------------------------------------------------------------------------------------------

(use-package spacemacs-theme
  :ensure t
  :defer t
  :custom
        (setq spacemacs-theme-comment-bg nil)
        (setq spacemacs-theme-comment-italic t)
  :init (load-theme 'spacemacs-dark t))

; (use-package gruvbox-theme
;       :ensure t
;   :init (load-theme 'gruvbox-dark-soft t))

;; --------------------------------------------------------------------------------------------
;; PACKAGES
;; --------------------------------------------------------------------------------------------
(require 'subr-x)
(require 'helm-config)

(use-package highlight-symbol
  :ensure t)

(use-package idle-highlight-mode
  :ensure t
  :custom
  (idle-highlight-idle-time 0.1)
  :hook
  ((prog-mode text-mode) . idle-highlight-mode))

;; Load Silver Searcher
(use-package ag
  :ensure t)

;; Load ripgrep
(use-package rg
  :ensure t)

(use-package xref
  :ensure t)

;; Get rid of unnecessary windows
(use-package popwin
  :ensure t
  :config
  (popwin-mode t))

(use-package all-the-icons
  :ensure t)

(use-package doom-modeline
  :after (all-the-icons)
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-project-detection 'auto
        doom-modeline-height 40)
  :custom
  (display-battery-mode t))

(use-package keycast
  :config
  ;; This works with doom-modeline, inspired by this comment:
  ;; https://github.com/tarsius/keycast/issues/7#issuecomment-627604064
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
	(add-hook 'pre-command-hook 'keycast--update t)
      (remove-hook 'pre-command-hook 'keycast--update)))
  (add-to-list 'global-mode-string '("" mode-line-keycast " "))
  (keycast-mode))

(use-package auto-complete
  :ensure t
  :config
  (global-auto-complete-mode t))

(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 1000
        recentf-save-file (concat user-emacs-directory ".recentf"))
  (recentf-mode t)
  :diminish nil)

(use-package org
  :ensure t
  :config
  (setq org-ellipsis " ▾")

  ;; start org-agenda in log-mode by default (like if 'a' option was chosen)
  (setq org-agenda-start-with-log-mode t)
  ;; whenever task is DONE - add information (log) about when the tash has been finished
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (my-org-font-setup)
  (my-set-org-agenda))

(use-package org-bullets
  :ensure t
  :after org
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; this package enables org notifications on your OS desktop
(use-package org-wild-notifier
  :ensure t)

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/org_roam_database")
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)
     ("m" "meeting" plain
      (file "~/org_roam_database/templates/meeting_template.org")
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "")
      :unnarrowed t)
     ("w" "words" plain
      (file "~/org_roam_database/templates/words_template.org")
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "")
      :unnarrowed t)
     ))
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 :map org-mode-map
	 ("C-M-i" . completion-at-point)
	 :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap "org-roam-dailies-map" is available
  (org-roam-db-autosync-mode))

;; Package that allows left/right side padding in org mode
(use-package visual-fill-column
  :defer t)

(use-package magit
  :ensure t
  :custom
  (magit-status-buffer-switch-function 'switch-to-buffer)
  :bind (("C-x g s" . magit-status)
         ("C-x g b" . magit-blame)
         ("C-x g c" . magit-checkout)))

(use-package projectile
  :ensure t
  :bind (
         ("<f7>"  . projectile-add-known-project)
         )
  :init
  (projectile-mode 1))

(use-package treemacs
  :ensure t
  :bind (
         ("<C-f5>" . treemacs)
         ("<C-f6>" . treemacs-add-project-to-workspace)
         )
  :config
  (treemacs-follow-mode t)
  (treemacs-git-mode 'deferred)
  ;; Make tremacs display nice indents in files hierarchy
  ;; (treemacs-indent-guide-mode 't)
  ;; (treemacs-indent-guide-style 'line)
  :custom
  ;; This fixes problem with helm buffers (e.g. helm-M-x)
  ;; ocupying the entire widow
  (treemacs-display-in-side-window nil)
  ;; Set default treemacs width, and unlock the
  ;; drag-and-drop resize option
  (treemacs-width 50)
  (treemacs-width-is-initially-locked nil)
  ;; Disable test wrapping in treemacs window, when widnow is to narrow
  (treemacs-wrap-around nil)
  )


(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :ensure t
  :config (treemacs-icons-dired-mode 1))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package helm-icons
  :ensure t
  :after (all-the-icons helm)
  :custom
  (helm-icons-provider 'all-the-icons)
  :config
  (helm-icons-enable))

(use-package treemacs-all-the-icons
  :ensure t
  :after (treemacs all-the-icons))

(use-package helm-ag
  :ensure t)

(use-package helm
  :ensure t
  :bind  (("M-x"     . helm-M-x)
          ("M-y"     . helm-show-kill-ring)
          ("C-x C-f" . helm-find-files)
          ("C-b"     . helm-buffers-list)
          ("C-x c o" . helm-occur)
          ("C-x r b" . helm-filtered-bookmarks)
          )
  :custom
  (helm-position 'bottom)
  ;; This fixes problem with helm buffers (e.g. helm-M-x)
  ;; ocupying the entire widow.
  ;; Although "helm-split-window-in-side-p" is deprecated
  ;; and superseeded "helm-split-window-inside-p", both
  ;; variables have to be set to t.
  (helm-split-window-in-side-p t)
  (helm-split-window-inside-p t)
  :init
  (helm-mode 1)
  (helm-autoresize-mode 1))

(use-package helm-swoop
  :ensure t
  :bind
  (("M-s"     . helm-swoop))
  :custom
  ;; This decreases helm swoop speed but in favour of colorded results
  (helm-swoop-speed-or-color t)
  ;; This fixes problem with helm-swoop appearing in another window,
  ;; when using multiple windows in one frame (treemacs / minimap)
  (helm-swoop-split-with-multiple-windows t)
  )

(use-package helm-xref
  :ensure t
  :after helm
  :commands helm-xref
  :config
  (setq xref-show-xrefs-function 'helm-xref-show-xrefs))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :bind(
        ("C-p"   . helm-projectile-find-file)
        ("C-l"   . helm-projectile-recentf)
        ("<f8>"  . helm-projectile-switch-project)
        ))

(use-package minimap
  :ensure t
  :custom
  (minimap-always-recenter nil)
  (minimap-hide-fringes t)
  (minimap-hide-scroll-bar nil)
  (minimap-highlight-line nil)
  (minimap-minimum-width 20)
  (minimap-recenter-type (quote relative))
  (minimap-recreate-window t)
  (minimap-update-delay 0)
  (minimap-width-fraction 0.06)
  (minimap-window-location (quote right))
  :custom-face
  (minimap-active-region-background ((((background dark)) (:background "#3c3c3c" :extend t)) (t (:background "#C847D8FEFFFF" :extend t))))
  (minimap-font-face ((t (:weight bold :height 15 :width normal :family "DejaVu Sans Mono"))))
  :config
  (minimap-mode -1))

 (use-package verilog-mode
   :ensure t
   :custom
   (verilog-align-ifelse t)
   (verilog-auto-delete-trailing-whitespace t)
   (verilog-auto-indent-on-newline t)
   (verilog-auto-newline nil)
   (verilog-highlight-grouping-keywords t)
   (verilog-highlight-modules t)
   (verilog-indent-level 2)
   (verilog-indent-level-behavioral 2)
   (verilog-indent-level-declaration 2)
   (verilog-indent-level-directive 0)
   (verilog-indent-level-module 2))

(use-package paredit
  :ensure t
  :init
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook #'enable-paredit-mode)
  :config
  (show-paren-mode t)
  (paredit-mode nil)
  :bind (("M-[" . paredit-wrap-square)
      ("M-{" . paredit-wrap-curly))
  :diminish nil)

(use-package highlight-indent-guides
  :ensure t
  :custom
  (highlight-indent-guides-method (quote character)))

(use-package drag-stuff
  :ensure t)

(use-package dumb-jump
  :ensure t)

;; --------------------------------------------------------------------------------------------
;; KEY BINDINGS
;; --------------------------------------------------------------------------------------------

(global-set-key (kbd "M-v")        #'scroll-half-page-down)
(global-set-key (kbd "C-v")        #'scroll-half-page-up)

(global-set-key (kbd "<f5>")       #'revert-buffer)
(global-set-key (kbd "<f6>")       #'kill-asterisk-buffers)
(global-set-key (kbd "<f9>")       #'minimap-mode)
(global-set-key (kbd "<f12>")      #'xref-find-definitions)

(global-set-key (kbd "<prior>")    #'drag-stuff-up)
(global-set-key (kbd "<next>")     #'drag-stuff-down)

(global-set-key (kbd "C-x 0")      #'kill-buffer-and-window)
(global-set-key (kbd "C-c d")      #'duplicate-current-line-or-region)
(global-set-key (kbd "C-c k")      #'kill-whole-line)
(global-set-key (kbd "C-c x")      #'delete-trailing-whitespace)
(global-set-key (kbd "C-c w")      #'toggle-highlight-trailing-whitespaces)
(global-set-key (kbd "C-c h")      #'toggle-idle-highlight-mode)
(global-set-key (kbd "C-c C-e")    #'eval-region)
(global-set-key (kbd "C-c C-,")    #'org-agenda-list)
(global-set-key (kbd "C-c t")      #'my-untabify-entire-buffer)

(global-set-key (kbd "C-c o i")    #'my-open-init-file)
(global-set-key (kbd "C-c o f")    #'my-open-custom-functions-file)
(global-set-key (kbd "C-c o c")    #'my-open-customization-file)

(global-set-key (kbd "C-x p r")    #'helm-projectile-recentf)
(global-set-key (kbd "C-x p R")    #'projectile-replace)
(global-set-key (kbd "C-x p x")    #'projectile-replace-regexp)

(define-key helm-map (kbd "TAB")   #'helm-execute-persistent-action)
(define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")   #'helm-select-action)

(global-set-key (kbd "C-,")        #'helm-projectile-grep)
(global-set-key (kbd "C-.")        #'helm-projectile-ag)

(define-key org-mode-map (kbd "C-x C-z")  #'outline-hide-entry)
(define-key org-mode-map (kbd "C-x C-a")  #'outline-hide-body)
(define-key org-mode-map (kbd "C-x C-n")  #'outline-next-heading)
(define-key org-mode-map (kbd "C-x C-p")  #'outline-prev-heading)

(define-key org-agenda-mode-map (kbd "m")  #'org-agenda-month-view)

(eval-after-load 'verilog-mode
  '(define-key verilog-mode-map (kbd "C-{") 'verilog-beg-of-defun))

(eval-after-load 'verilog-mode
  '(define-key verilog-mode-map (kbd "C-}") 'verilog-end-of-defun))

;; --------------------------------------------------------------------------------------------
;; HOOKS
;;
;; List of emacs hooks:
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Standard-Hooks.html
;; --------------------------------------------------------------------------------------------

;; PROG
(add-hook 'prog-mode-hook 'toggle-truncate-lines)
(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;; ORG
(add-hook 'org-mode-hook #'my-org-mode-setup)
(add-hook 'org-mode-hook #'org-bullets-mode)
(add-hook 'org-mode-hook #'my-org-mode-visual-fill)

;; POST COMMAND
;; (add-hook 'post-command-hook #'highlight-syntax-duplicates)

;; KILL BUFFER / QUIT WINDOW
;; (add-hook 'kill-buffer-hook <fun>)
;; (add-hook 'quit-window-hook <fun>)

;; XREF
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
;; Comment below line - use 'helm-xref' instead as it works better
;; (setq xref-show-definitions-function #'xref-show-definitions-completing-read)

;; MINIBUFFER
(defun my-minibuffer-setup ()
  "Function sets minibuffer font larger"
  (set (make-local-variable 'face-remapping-alist)
       '((default :height 1.3))))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup)

;; --------------------------------------------------------------------------------------------
;; OTHER SETTINGS
;; --------------------------------------------------------------------------------------------

; (set-face-attribute 'default nil :font "Fira Code Retina" :height default-font-size)

; ;; Set the fixed pitch face
; (set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 260)

; ;; Set the variable pitch face
; (set-face-attribute 'variable-pitch nil :font "Cantarell" :height 295 :weight 'regular)

(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1))))

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

(set-face-attribute 'default nil :height 120)

(global-hl-line-mode 1)
(set-face-background hl-line-face "gray13")

(blink-cursor-mode 1)
(delete-selection-mode 1)
(column-number-mode 1)

(setq-default show-trailing-whitespace 1)
(setq-default explicit-shell-file-name "/bin/bash")

;; full screen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; mouse behaviour
;; (setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; Hide org emphasis characters, like *, =, -, + etc.
(setq org-hide-emphasis-markers t)

;; Bind certain org emphasis functionalities to certain keys
(setq org-emphasis-alist
      (quote (("*" bold)
              ("/" italic)
              ("_" underline)
              ("=" (:foreground "yellow" :background "black"))
              ("~" org-verbatim verbatim)
              ("+"
               (:strike-through t))
              )))

;; Tramp issues explanation (solution works !):
;;   https://emacs.stackexchange.com/questions/24159/tramp-waiting-for-prompts-from-remote-shell
;; (setq tramp-shell-prompt-pattern "^[^$>\n]*[#$%>] *\\(\[[0-9;]*[a-zA-Z] *\\)*")

;; --------------------------------------------------------------------------------------------
;; BABEL SETTINGS
;; --------------------------------------------------------------------------------------------

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (octave . t)
   (emacs-lisp . t)))

;; Set Babel to use Python 3
(setq org-babel-python-command "python3")

;; Example from Babel Introduction
;; (setq org-babel-default-header-args
;;       (cons '(:noweb . "yes")
;;             (assq-delete-all :noweb org-babel-default-header-args)))

;; Fundamental functions
;; In Lisp, car, cdr, and cons are fundamental functions.
;; The cons function is used to construct lists, and the car and cdr functions are used to take them apart.
;; Source: https://www.gnu.org/software/emacs/manual/html_node/eintr/car-cdr-_0026-cons.html

;; (car '(a b c))
;; (cdr '(a b c))
;; (nthcdr 2 '(pine fir oak maple))
;; (nthcdr 4 '(pine fir oak maple))
;; (cons 'a '(c d))
;; (cons '(a b) '(c d))
;; (setq mylist (cons '(add) '(to list)))
;; (assq-delete-all 'add mylist)

(message "... finished reading ~/.emacs.d/init.el")
