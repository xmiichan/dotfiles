;; -*- lexical-binding: t; -*-


(setq warning-suppress-log-types '((files missing-lexbind-cookie)))

;; setup package management
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(unless package-archive-contents
  (package-refresh-contents))

;; keep emacs directory clean
(use-package no-littering
  :ensure t
  :demand t
  :init
  (setq no-littering-etc-directory
        (expand-file-name "etc/" user-emacs-directory)
        no-littering-var-directory
        (expand-file-name "var/" user-emacs-directory))
  :config
  (no-littering-theme-backups)
  (let ((dir (no-littering-expand-var-file-name "lockfiles/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t)))))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error :no-message)

;; fix issues with path
(use-package exec-path-from-shell
  :ensure t
  :demand t
  :if (eq system-type 'darwin)
  :custom
  (exec-path-from-shell-arguments nil)
  (exec-path-from-shell-variables
   '("PATH" "MANPATH" "XDG_RUNTIME_DIR" "SSH_AUTH_SOCK"))
  :config
  (exec-path-from-shell-initialize))

;; start server if not running
(require 'server)
(setq server-socket-dir
      (expand-file-name
       "emacs" (or (getenv "XDG_RUNTIME_DIR") (getenv "TMPDIR"))))
(unless (server-running-p)
  (server-start))
(add-hook 'server-after-make-frame-hook
          (lambda () (select-frame-set-input-focus (selected-frame))))

(setq my/backup-mode-line mode-line-format)

(setq-default mode-line-format
	      my/backup-mode-line)
(setopt mode-line-compact 'long)

;; ui cleanup
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq mode-line-collapse-minor-modes
      '(anzu-mode eldoc-mode which-key-mode))

;; fonts and theme
(setq default-frame-alist
      '((font . "Sarasa Fixed J-16")
        (ns-appearance . dark)
        (ns-transparent-titlebar . t)))

(custom-set-faces
 '(fixed-pitch ((t (:family "Sarasa Fixed J"))))
 '(fixed-pitch-serif ((t (:family "Sarasa Fixed Slab J"))))
 '(variable-pitch ((t (:family "Sarasa UI J")))))

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker :no-confirm))

;; macos keys
(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta
        ns-right-option-modifier nil))

;; disable annoyances
(setq use-dialog-box nil
      ring-bell-function 'ignore
      inhibit-startup-message t
      display-line-numbers-type 'visual
      tab-always-indent 'complete)

;; make sure ESC ESC ESC doesn't close splits
(advice-add #'keyboard-escape-quit :around
            (lambda (orig)
	      (let ((buffer-quit-function (or buffer-quit-function #'ignore)))
		(funcall orig))))

;; qol settings
(advice-add #'yes-or-no-p :override #'y-or-n-p)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode)
  (add-hook hook #'hl-line-mode))
(recentf-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)
(which-key-mode 1)
(repeat-mode 1)

(keymap-global-set "C-x C-b" #'ibuffer)
(setq ibuffer-saved-filter-groups
      '(("Dired" (mode . dired-mode))
        ("Org" (or (filename . ".org") (mode . org-mode)))))

(defun my/pulse-current-region (&rest _)
  "Pulse the current implicit or active region."
  (if mark-active
      (pulse-momentary-highlight-region (region-beginning) (region-end))
    (pulse-momentary-highlight-region (mark) (point))))
(advice-add #'kill-ring-save :before #'my/pulse-current-region)

;; project stuff
(setq project-vc-extra-root-markers '(".project"))

(use-package project-tab-groups
  :ensure t
  :config
  (project-tab-groups-mode 1))

;; treesitter
(setopt treesit-enabled-modes t)
(setq treesit-auto-install-grammar 'ask)

;; lsp
(dolist (hook '(rust-ts-mode-hook
                typescript-ts-mode-hook tsx-ts-mode-hook
                c-mode-hook c-ts-mode-hook c++-mode-hook c++-ts-mode-hook
                sh-mode-hook bash-ts-mode-hook))
  (add-hook hook #'eglot-ensure))
(setq flymake-show-diagnostics-at-end-of-line 'short)

;; useful packages
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package consult
  :ensure t
  :bind
  (([remap switch-to-buffer] . consult-buffer)
   ([remap project-switch-to-buffer] . consult-project-buffer)
   ([remap yank-pop] . consult-yank-pop)
   ([remap imenu] . consult-imenu)
   ("M-g M-g" . consult-line)
   ("M-g o" . consult-outline)
   ("M-g f" . consult-flymake)
   ("M-s M-s" . consult-ripgrep)
   ("M-s k" . consult-focus-lines)
   :map minibuffer-local-map
   ("M-r" . consult-history))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package helpful
  :ensure t
  :bind
  (([remap describe-function] . #'helpful-function)
   ([remap describe-variable] . #'helpful-variable)
   ([remap describe-command] . #'helpful-command)
   ([remap describe-key] . #'helpful-key)))

(use-package paredit
  :ensure t
  :hook
  ((emacs-lisp-mode lisp-mode lisp-interaction-mode) . enable-paredit-mode)
  :config
  (keymap-unset paredit-mode-map "M-s" t)
  (keymap-set paredit-mode-map "M-D" #'paredit-splice-sexp))

(use-package multiple-cursors
  :ensure t
  :bind
  (("C-c C-n" . #'mc/mark-next-like-this)
   ("C-c C-p" . #'mc/mark-previous-like-this)
   ("C-c C-a" . #'mc/mark-all-dwim)
   ("C-c C-l" . #'mc/edit-lines)
   (:repeat-map mc/repeat-map
                ("C-n" . #'mc/mark-next-like-this)
                ("C-p" . #'mc/mark-previous-like-this))))

(use-package magit
  :ensure t
  :bind
  (("C-x g" . #'magit)))

(use-package avy
  :ensure t
  :bind
  (("C-'" . #'avy-goto-char-timer)))

(use-package anzu
  :ensure t
  :config
  (global-anzu-mode +1)
  :bind
  (([remap query-replace] . #'anzu-query-replace)
   ([remap query-replace-regexp] . #'anzu-query-replace-regexp)))

;; org mode fun
(use-package org
  :ensure t
  :hook
  ((org-mode . org-indent-mode)
   (org-mode . flyspell-mode)
   (org-mode . visual-line-mode)
   (org-mode . (lambda ()
                 (hl-line-mode -1)
                 (display-line-numbers-mode -1)))))

(use-package org-modern
  :ensure t
  :after (org)
  :config
  (global-org-modern-mode 1))

(load (expand-file-name "local.el" user-emacs-directory) :no-error :no-message)

