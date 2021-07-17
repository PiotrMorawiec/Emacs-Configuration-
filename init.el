;; --------------------------------------------------------------------------------------------
;;TODO
;; --------------------------------------------------------------------------------------------
;; * zrobić coś żeby emacs nie oteiral kazdego polecenia (np helm) w nowym buforze
;; * fix helm-swoop in prog-mode
;; * poprawić performance - spowolnienia są wprowadzane w znaczej mierzez przez GC (Garbage Collection)
;; * performance - timer (jest wprowadzany przez minimap)
;; --------------------------------------------------------------------------------------------

;; --------------------------------------------------------------------------------------------
;; USEFULL FUNCTIONS
;; --------------------------------------------------------------------------------------------
;;
;; list-colors-display
;; list-faces-display
;;
;; --------------------------------------------------------------------------------------------

(message "Start reading ~/.emacs.d/init.el ...")

;; --------------------------------------------------------------------------------------------
;; SOME INIT ACTIONS
;; --------------------------------------------------------------------------------------------

;; Do not show the startup screen.
;; (setq inhibit-startup-message t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

;; Do not use `init.el` for `custom-*` code (generated by 'M-x customize' menu) - use `custom-file.el`.
(setq custom-file "~/.emacs.d/custom-file.el")

;; Assuming that the code in custom-file is execute before the code
;; ahead of this line is not a safe assumption. So load this file
;; proactively.
(load-file custom-file)

(add-to-list 'load-path "~/.emacs.d/lisp-custom-libs")
(require 'custom-functions)

;; --------------------------------------------------------------------------------------------
;; SETUP PACKAGE REPOSITORIES
;; --------------------------------------------------------------------------------------------

(require 'package)

(add-to-list 'package-archives '("gnu"          . "https://elpa.gnu.org/packages/")     t)
(add-to-list 'package-archives '("melpa"        . "https://melpa.org/packages/")        t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)
(package-refresh-contents)

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
; 	:ensure t
;   :init (load-theme 'gruvbox-dark-soft t))

; (use-package doom-themes
;   :init (load-theme 'doom-dracula t))

;; --------------------------------------------------------------------------------------------
;; PACKAGES
;; --------------------------------------------------------------------------------------------
(require 'subr-x)
(require 'helm-config)

(use-package all-the-icons)

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

;; (use-package smex
;;   :ensure t
;;   ;; Using counsel-M-x for now. Remove this permanently if counsel-M-x works better.
;;   :disabled t
;;   :config
;;   (setq smex-save-file (concat user-emacs-directory ".smex-items"))
;;   (smex-initialize)
;;   :bind ("M-x" . smex))

(use-package org
  :ensure t)

;; This package will replace asterisk's in org-mode to fancy bullet's icons
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package magit
  :ensure t
  :bind ("C-x g s" . magit-status))

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
	 ("<f5>" . treemacs)
	 ("<f6>" . treemacs-add-project-to-workspace)
	 )
  :config
  (treemacs-follow-mode -1)
  (treemacs-git-mode 'deferred))


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
  :after (treemacs helm)
  :config
  (helm-icons-enable))

(use-package helm
  :ensure t
  :bind  (("M-x"     . helm-M-x)
	  ("C-x C-f" . helm-find-files)
	  ("C-x b"   . helm-buffers-list)
	  ("C-x c o" . helm-occur)
	  ("M-y"     . helm-show-kill-ring)
	  ("C-x r b" . helm-filtered-bookmarks)
	  )
  :custom
  (helm-position 'bottom)
  :init 
  (helm-mode 1)
  (helm-autoresize-mode 1))

(use-package helm-swoop
  :ensure t
  :bind
  (("M-s"     . helm-swoop))
  :custom
  (helm-swoop-speed-or-color t))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :bind(
	("C-p"   . helm-projectile-find-file)
	("<f8>"  . helm-projectile-switch-project
	 )))


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
  :config
  (minimap-mode -1))

(use-package verilog-mode
  :ensure t)

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

(global-set-key (kbd "M-v")       'scroll-half-page-down)
(global-set-key (kbd "C-v")       'scroll-half-page-up)

(global-set-key (kbd "<f9>")      'minimap-mode)
(global-set-key (kbd "<f12>")     'xref-find-definitions)

(global-set-key (kbd "<prior>")   'drag-stuff-up)
(global-set-key (kbd "<next>")    'drag-stuff-down)

(global-set-key (kbd "C-c d")     'duplicate-current-line-or-region)
(global-set-key (kbd "C-c k")     'kill-whole-line)
(global-set-key (kbd "C-c x")     'delete-trailing-whitespace)

(define-key helm-map (kbd "TAB")   #'helm-execute-persistent-action)
(define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")   #'helm-select-action)

(define-key org-mode-map (kbd "C-x C-z")  #'outline-hide-entry)
(define-key org-mode-map (kbd "C-x C-a")  #'outline-hide-body)

;; --------------------------------------------------------------------------------------------
;; HOOKS
;; --------------------------------------------------------------------------------------------

;; PROG
(add-hook 'prog-mode-hook 'toggle-truncate-lines)
(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)

;; ORG
; (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; POST COMMAND
; (add-hook 'post-command-hook 'toggle-highlight-region-duplicates)

;; XREF
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
; (setq xref-show-definitions-function #'xref-show-definitions-completing-read)

;; MINIMAP
(defun my-minibuffer-setup ()
       (set (make-local-variable 'face-remapping-alist)
          '((default :height 1.3))))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup)

;; --------------------------------------------------------------------------------------------
;; OTHER SETTINGS
;; --------------------------------------------------------------------------------------------

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


(message "... finished reading ~/.emacs.d/init.el")