;;; early-init.el --- Pre-initialization file for Emacs -*- lexical-binding: t -*-

;;; Commentary:
;; Runs before package and UI init happens.

;;; Code:
;; Up the GC threshold during the init phase.
;; Reset it to default afterwards.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'after-init-hook (lambda () (setq gc-cons-threshold (* 1024 1024 24))))

;; Increase the amount of data which Emacs reads from the process to 1 MB.
(setq read-process-output-max (* 1024 1024))

;; Change the location of the native compilation cache.
(when (and (native-comp-available-p) (fboundp 'startup-redirect-eln-cache))
  (startup-redirect-eln-cache
   (convert-standard-filename
	(expand-file-name  "var/eln-cache/" user-emacs-directory))))

;;; early-init.el ends here
