;;; publish.el --- Export journal to HTML -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Eduardo V.
;;
;; Author: Eduardo V. <https://github.com/LaloHao>
;; Maintainer: Eduardo V. <lalohao@gmail.com>
;; Created: October 07, 2021
;; Modified: April 30, 2022
;; Version: 0.0.1
;; Keywords: journal
;; Homepage: https://github.com/LaloHao/journal
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

(use-package! ox-publish)
(use-package! htmlize)

 (defun faces-on (beg end)
   "Collect all (unique) faces from `BEG' to `END'."
   (let (words)
     `(default .
        ,(-non-nil (remove-if (-orfn #'keywordp #'stringp) (-flatten (save-excursion
        ;; ,(-non-nil (-flatten (save-excursion
        ;; ,(save-excursion
            (goto-char beg)
            (save-restriction
              (narrow-to-region beg end)
              (while (setq match (text-property-search-forward 'face nil nil))
                (pushnew (get-text-property (point) 'face)
                         words :test #'equal)))
            words)))))))

 ;; (faces-on (point-min) (point-max)) => (default rainbow-delimiters-depth-2-face highlight-quoted-symbol font-lock-constant-face font-lock-function-name-face rainbow-delimiters-depth-3-face font-lock-doc-face font-lock-constant-face font-lock-doc-face font-lock-keyword-face rainbow-delimiters-depth-1-face font-lock-comment-delimiter-face font-lock-comment-face)
 ;; (faces-on 1 1)

 (defun theme-face (face &optional theme)
   (let ((theme (or theme (car custom-enabled-themes))))
     `(,face ((t ,(car (cdaadr (assoc theme (get `,face 'theme-face)))))))))

 ;; (theme-face 'default 'doom-one) => (default ((t (:background "#282c34" :foreground "#bbc2cf"))))

 (setq htmlize-use-rgb-map 'force)

 (defvar line 'line)

 (setq render-theme 'doom-challenger-deep)

 (load-theme render-theme t)

 (defface line
 '((t (:foreground "red")))
   "A line.")

 ;; (save-excursion
 ;;   (goto-char (point-min))
 ;;   ;; (dotimes (line ()))
 ;;   (while (not (eobp))
 ;;     (let* ((lb (line-beginning-position))
 ;;            (le (line-end-position))
 ;;            ;; (ss (buffer-substring lb le))
 ;;            (ov (make-overlay lb lb)))
 ;;       (goto-char lb)
 ;;       ;; (insert (propertize (format "%4s | " (line-number-at-pos)) 'face 'line))
 ;;       (insert (propertize " " 'face 'line))
 ;;       ;; (overlay-put ov 'before-string
 ;;       ;;   (propertize (format "%4s | " (line-number-at-pos)) 'face 'line))
 ;;       ;; (overlay-put ov 'display (propertize ss
 ;;       ;;                           'face 'line))
 ;;       ;; (insert (propertize " " 'face 'line 'display " "))
 ;;       (forward-line 1))))

(defun render-faces ()
  "Render faces on buffer."
  (let* ((faces (faces-on (point-min) (point-max)))
         (spec (--map (theme-face it render-theme) faces)))
    (princ faces)
    ;; (kill-emacs)
    (apply #'custom-set-faces spec)))

(defun export-file (plist file dir)
  "Export org `FILE' to `DIR'."
  (let ((output (expand-file-name
          (concat dir "/" (file-name-base file) ".html"))))
    (save-window-excursion
      (save-excursion
        (message "(1/4) Exporting %s" output)
        (find-file file)
        (message "(2/4) Rendering %s" output)
        (font-lock-fontify-buffer)
        (render-faces)
        (message "(3/4) HTMLizing %s" output)
        (with-current-buffer (htmlize-buffer)
          (write-file output))
        (message "(4/4) Saved %s" output)))
    output))

;; (with-current-buffer (htmlize-buffer)
;;   (princ (buffer-string)))

(setq org-publish-project-alist
  '(("journal"
     :recursive t
     :base-directory "./"
     :publishing-directory "/tmp/journal"
     ;; :publishing-function org-html-publish-to-html
     :publishing-function export-file
     :with-author nil
     :with-creator t
     :with-toc t
     :time-stamp-file nil
     )))

(org-publish-all t)

(message "Done")

(provide 'publish)
;;; publish.el ends here
