;; -*- lexical-binding: t; -*-

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages//") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(use-package no-littering
  :ensure t
  :demand t
  :init
  (setq no-littering-etc-directory
        (expand-file-name "etc/" user-emacs-directory))
  (setq no-littering-var-directory
        (expand-file-name "var/" user-emacs-directory))
  :config
  (no-littering-theme-backups)
  (let ((dir (no-littering-expand-var-file-name "lockfiles/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t)))))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error :no-message)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq display-line-numbers-type 'visual)
(setq tab-always-indent 'complete)

(global-display-line-numbers-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)
(which-key-mode 1)
(repeat-mode 1)

(setq use-dialog-box nil)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-message t)

(set-frame-font "Iosevka 16" nil t)

(global-set-key (kbd "C-x C-b") #'ibuffer)
(setq ibuffer-saved-filter-groups
      '(("Dired" (mode . dired-mode))
    	("Org" (or (filename . ".org") (mode . org-mode)))))

(when (eq system-type 'darwin)
  (set-frame-parameter nil 'ns-appearance 'dark)
  (set-frame-parameter nil 'ns-transparent-titlebar t)
  (setq ns-command-modifier 'meta)
  (setq ns-right-option-modifier nil))

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker :no-confirm))

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
  ((emacs-lisp-mode lisp-mode lisp-interaction-mode) . #'enable-paredit-mode)
  :config
  (with-eval-after-load 'paredit
    (keymap-unset paredit-mode-map "M-s" t)
    (define-key paredit-mode-map (kbd "M-D") #'paredit-splice-sexp)))

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
