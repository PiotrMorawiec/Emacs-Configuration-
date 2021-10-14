

(defun scroll-half-page-down ()
        "scroll down half the page"
        (interactive)
        (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
        "scroll up half the page"
        (interactive)
        (scroll-up (/ (window-body-height) 2)))

(defvar sel-region "")
(defun toggle-highlight-region-duplicates ()
        "Function toggles higlight of all occurances of currently selected region"
        (interactive)
        (if (and (use-region-p) (> (region-end) (+ (region-beginning) 1)))
            (progn
              (setq sel-region (buffer-substring (region-beginning) (region-end)))
              (highlight-regexp sel-region 'region))
          (unhighlight-regexp t)))


(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end) (point))
      (goto-char (+ origin (* (length region) arg) arg)))))

(defun toggle-highlight-trailing-whitespaces ()
  "Function toggles highlighting trailing whitespaces"
  (interactive)
  (if (= show-trailing-whitespace 1)
      (progn  (message "Disable highlighting of trailing whitespaces")
              (setq-default show-trailing-whitespace nil))
  (progn (message "Enable highlighting of trailing whitespaces")
         (setq-default show-trailing-whitespace 1))))

(defun which-active-modes ()
  "Give a message of which minor modes are enabled in the current buffer."
  (interactive)
  (let ((active-modes))
    (mapc (lambda (mode) (condition-case nil
                             (if (and (symbolp mode) (symbol-value mode))
                                 (add-to-list 'active-modes mode))
                           (error nil) ))
          minor-mode-list)
    (message "Active modes are %s" active-modes)))


(setq-default explicit-shell-file-name "/bin/bash")

(defun my-term ()
  "My personal term command."
  (interactive)
  (set-buffer (make-term "terminal" explicit-shell-file-name))
  (term-mode)
  (term-char-mode)
  (switch-to-buffer "*terminal*"))

(defun my-org-mode-setup ()
  (interactive)
  (org-indent-mode)
  (variable-pitch-mode 1) ;; < what is that ?
  ;; Enable text wrapping in org-mode (it looks better when side piddings enbaled)
  (visual-line-mode 1))

(defun my-org-font-setup ()
  (interactive)
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))


(defun my-org-mode-visual-fill ()
  "Function imposes left and right side paddings in org-mode"
  (interactive)
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(defun my-set-org-agenda ()
  "Sets all agenda files for org-mode"
  (interactive)
  (setq org-agenda-files
  '("~/projects/pusch/org/agenda.org")))

(defun my-set-org-tutorial-agenda ()
  (interactive)
  (setq org-agenda-files
  '(;;"~/projects/pusch//org/placeholder.org"
    "~/programming/org/tutorial/tips.org")))

(defun my-untabify-entire-buffer ()
  (interactive)
  (mark-whole-buffer)
  (untabify (region-beginning) (region-end))
  (message "Converting all TAB's to spaces")
  (keyboard-quit))

(defun my-open-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el")
  (message "Init file opened"))

(provide 'custom-functions)
