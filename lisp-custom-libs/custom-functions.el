

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

(defun my/term ()
  "My personal term command."
  (interactive)
  (set-buffer (make-term "terminal" explicit-shell-file-name))
  (term-mode)
  (term-char-mode)
  (switch-to-buffer "*terminal*"))

(provide 'custom-functions)
