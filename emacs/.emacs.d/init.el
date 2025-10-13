;;; init.el --- Initialization file for Emacs -*- lexical-binding: t -*-

;;; Commentary:
;; My Emacs config. Meant for Emacs 29 and above.

;;; Code:

;;;; Basic config
(require 'cl-lib)

;; Start server if it's not already running.
(require 'server)
(unless (server-running-p)
  (server-start))

;; Do not resize the frame at this early stage.
(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)

;; Inhibit cl warning
(setq byte-compile-warnings '(cl-functions))

;; Frame layout.
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(alpha-background . 95))
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

;; Usp plists for deserialization (speeds up lsp-mode)
(setenv "LSP_USE_PLISTS" "true")

;; Setup package management.
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(setq package-archive-priorities
      '(("gnu"    . 20)
        ("nongnu" . 10)
        ("melpa"  . 0)))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-enable-imenu-support t)
(setq package-install-upgrade-built-in t)
(require 'use-package)

;; Setup no-littering as early as possible.
(use-package no-littering
  :ensure t
  :config
  ;; Don't litter init.el with customs.
  (no-littering-theme-backups)
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (load custom-file :noerror :nomessage)
  ;; recentf suppport.
  (require 'recentf)
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-etc-directory)))

;; Optimized garbage collection.
(if (>= emacs-major-version 27)
    (add-function :after after-focus-change-function #'garbage-collect)
  (with-no-warnings
    (add-hook 'focus-out-hook #'garbage-collect)))

;; Inhibit async native-comp warnings.
(when (and (>= emacs-major-version 28)
           (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors nil))

;; Add lexical binding to scratch buffer.
(setq initial-scratch-message ";; -*- lexical-binding: t -*-\n\n")

;; Hide commands in M-x that do not apply to the current mode.
(when (>= emacs-major-version 28)
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; Confirm kill
(setq confirm-kill-emacs #'y-or-n-p)

;; Mouse support
(xterm-mouse-mode +1)

;; Improve MacOS keys
;; Right Alt is used for symbols, left Cmd becomes an additional Meta.
(when (eq system-type 'darwin)
  (setq ns-right-option-modifier nil)
  (setq ns-option-modifier 'super)
  (setq ns-command-modifier 'meta)
  ;; Allow for CUA copying so integration with other apps works better.
  (bind-key "M-c" #'kill-ring-save)
  (bind-key "s-c" #'capitalize-word))

;; Copy/paste on Wayland.
(exec-path-from-shell-copy-env "WAYLAND_DISPLAY")
(when (getenv "WAYLAND_DISPLAY")
  (setq wl-copy-process nil)
  (defun wl-copy (text)
    (setq wl-copy-process
          (make-process
           :name "wl-copy"
           :buffer nil
           :command '("wl-copy" "-f" "-n")
           :connection-type 'pipe
           :noquery t))
    (process-send-string wl-copy-process text)
    (process-send-eof wl-copy-process))
  (defun wl-paste ()
    (if (and wl-copy-process (process-live-p wl-copy-process))
        nil                 ; should return nil if we're the current paste owner
      (shell-command-to-string "wl-paste -n | tr -d \r")))
  (setq interprogram-cut-function 'wl-copy)
  (setq interprogram-paste-function 'wl-paste))

;; GPG integration
(use-package epg
  :config
  (setq epg-pinentry-mode 'loopback))

(use-package pinentry
  :ensure t
  :after epg
  :config
  (pinentry-start))

(use-package auth-source
  :init
  (add-to-list 'auth-sources (expand-file-name ".authinfo.gpg" user-emacs-directory))

  (defun my/auth-source-get (host key)
    "Get value for KEY for HOST from authinfo file."
    (plist-get
     (car (auth-source-search :host host))
     key)))

;; SSH keychain.
(use-package keychain-environment
  :ensure t
  :if (executable-find "keychain")
  :config
  (keychain-refresh-environment))

;; Emacs on Mac OS messes up PATH. Let's fix that.
(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-arguments nil)

  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))

  (when (daemonp)
    (add-hook 'server-after-make-frame-hook #'exec-path-from-shell-initialize)))

(use-package mise
  :ensure t
  :hook
  ((after-init . global-mise-mode)))

;; Enable region-binding mode early so other packages can use it.
(use-package region-bindings-mode
  :ensure t
  :config
  (region-bindings-mode-enable))

(defun unfill-region (beg end)
  "Unfill the region from BEG to END, joining text into a single logical line.
This is useful, e.g., for use with `visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

;; Some performance tweaks.
(setq load-prefer-newer t)
(setq large-file-warning-threshold 100000000)

(defun my/minibuffer-setup-hook ()
  "Disable GC while in the minibuffer."
  (setq gc-cons-threshold most-positive-fixnum))

(defun my/minibuffer-exit-hook ()
  "Reenable GC upon exiting the minibuffer."
  (setq gc-cons-threshold (* 1024 1024 24)))

(add-hook 'minibuffer-setup-hook #'my/minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my/minibuffer-exit-hook)

;; Enable auto-saving.
(defun my/file-not-encrypted-p ()
  "Return T if the visited file is not encrypted."
  (not (string-match epa-file-name-regexp buffer-file-name)))

(defun my/inhibit-backups-when-encrypted ()
  "Disable backups for encrypted files."
  (when (string-match epa-file-name-regexp buffer-file-name)
    (setq-local backup-inhibited t)))

(setq auto-save-visited-predicate #'my/file-not-encrypted-p)
(add-hook 'find-file-hook #'my/inhibit-backups-when-encrypted)

;; Don't show menu bar.
(menu-bar-mode -1)

;; Allow single-key command repetition.
(repeat-mode +1)

(setq ring-bell-function 'ignore)
(setq completion-cycle-threshold 3)

;; Some quality of life chages.
(column-number-mode t)
(size-indication-mode t)
(delete-selection-mode 1)
(electric-pair-mode 1)
(setq sentence-end-double-space nil)
(setq split-height-threshold nil)
(setq split-width-threshold 160)
(setq isearch-lazy-count t)
(setq lazy-count-prefix-format "(%s/%s) ")

;; Enable casing commands.
(put #'upcase-region 'disabled nil)
(put #'downcase-region 'disabled nil)
;; Also list-timers.
(put #'list-timers 'disabled nil)

;; Save bookmarks after every change.
(setq bookmark-save-flag 1)

(use-package recentf
  :after no-littering
  :init
  (recentf-mode +1)
  :bind
  (("C-x C-." . recentf))
  :config
  (add-to-list 'recentf-exclude "\\elpa"))

;; Clean up whitespace on save.
(add-hook 'before-save-hook #'whitespace-cleanup)

;; Remember position in file between sessions.
(use-package saveplace
  :init
  (save-place-mode +1)
  :config
  (setq-default save-place t))

;; Remember history between sessions.
(use-package savehist
  :after no-littering
  :init
  (setq history-length 25)
  (savehist-mode +1)
  :config
  (setq savehist-additional-variables
        '(search-ring regexp-search-ring register-alist kill-ring))
  (setq savehist-autosave-interval 60))

(setq undo-limit 1600000)
(setq undo-strong-limit 2400000)

(use-package undohist
  :after no-littering
  :ensure t
  :config
  (undohist-initialize)
  (add-to-list 'undohist-ignored-files "COMMIT_EDITMSG"))

;; Edit file as another user.
(use-package sudo-edit
  :ensure t)

;; Revert buffer when the file changes.
(use-package autorevert
  :config
  ;; (global-auto-revert-mode +1)
  (setq global-auto-revert-non-file-buffers t))

;; Use TAB for indenting the current line or insert a completion-at-point.
(setq tab-always-indent 'complete)
(setq-default tab-width 4)

;;;; User interface
;; Better buffer naming.
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;; Make Emacs look better by disabling some stuff.
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(setq visible-cursor nil)
(setq use-dialog-box nil)
(setq inhibit-splash-screen t)

;; Splitting behavior
(setq split-width-threshold 200)
(setq split-height-threshold nil)

;; Compilation buffer behavior
(setq compilation-scroll-output 'first-error)

;; Nice scrolling.
(setq scroll-margin 3
      scroll-conservatively 100000
      scroll-preserve-screen-position nil)

;; Wrapping
(use-package wrap-region
  :ensure t
  :init
  (wrap-region-mode t))

;; Line numbers
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Shorter confirm commands.
(fset #'yes-or-no-p #'y-or-n-p)

(defun my/save-buffers-kill-terminal ()
  "Like `save-buffers-kill-terminal' but ask first."
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to close this frame? "))
      (save-buffers-kill-terminal)
    (message "Frame not closed. :)")))

(when (daemonp)
  (global-set-key (kbd "C-x C-c") #'my/save-buffers-kill-terminal))

;; Frame title should the file name.
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; Use spaces for indentation by default and warn on long lines.
(setq-default indent-tabs-mode nil)
(setq-default fill-column 80)

;; 24-hour clock
(setq display-time-24hr-format t)

;; Highlight region when executing commands on it.
(defun my/pulse-current-region (&rest _)
  "Pulse the current implicit or active region."
  (if mark-active
      (pulse-momentary-highlight-region (region-beginning) (region-end))
    (pulse-momentary-highlight-region (mark) (point))))

(setq copy-region-blink-delay 0)
(advice-add #'kill-ring-save :before #'my/pulse-current-region)

;; Highlight matching parens.
(use-package paren
  :init
  (setq show-paren-style 'parenthesis)
  (setq show-paren-when-point-in-periphery t)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-context-when-offscreen 'overlay)
  (show-paren-mode +1))

;; Highlight current line.
(use-package hl-line
  :init
  (global-hl-line-mode +1))

(use-package hl-line+
  :load-path "modules"
  :defer nil
  :custom
  (hl-line-inhibit-highlighting-for-modes '(org-mode)))

;; ANSI colours in the compilation buffer
(use-package ansi-color
  :config
  (defun my/colourize-compilation-buffer ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max))))

  (add-hook 'compilation-filter-hook #'my/colourize-compilation-buffer))

;; Truncate lines instead of wrapping them.
(setq truncate-lines t)

;; Fonts
(defvar default-font
  (font-spec :family "Sarasa Mono J" :size 16 :weight 'regular))

(defvar fixed-serif-font
  (font-spec :family "Sarasa Mono Slab J" :size 16 :weight 'regular))

(defvar var-pitch-font
  (font-spec :family "Sarasa Gothic J" :size 16 :weight 'regular))

(defvar emoji-font
  (font-spec :family "OpenMoji"))

;; This is not necessary when using a nerd font as `default-font', but it's nice
;; to have a fallback just in case. Also the Symbols Nerd Font is the one that
;; comes with the package and has the corrects width for most things in Emacs.
;; NOTE: Don't set a size here so it will use the size of whatever font
;; it's filling in for.
(defvar nerd-font
  (font-spec :family "IosevkaTerm Nerd Font" :weight 'regular))

(defun my/after-make-frame ()
  "Setup for new frames. Intended for `after-make-frame-functions'."
  (when (display-graphic-p)
    ;; Setup fonts.
    (set-frame-font default-font t t)
    (set-face-attribute 'fixed-pitch nil :font default-font)
    (set-face-attribute 'fixed-pitch-serif nil :font fixed-serif-font)
    (set-face-attribute 'variable-pitch nil :font var-pitch-font)
    (setq use-default-font-for-symbols nil)
    (set-fontset-font t 'unicode default-font nil)
    (set-fontset-font t 'unicode nerd-font nil 'append)
    (set-fontset-font t 'unicode "Symbola" nil 'append)
    (set-fontset-font t 'unicode emoji-font nil 'append))
  ;; Use unicode encodings.
  (prefer-coding-system 'utf-8)
  (menu-bar-mode -1))

(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/after-make-frame)
  (my/after-make-frame))

;; Theme and color stuff.
(require-theme 'modus-themes)
(setq modus-themes-common-palette-overrides
      `((border-mode-line-active unspecified)
        (border-mode-line-inactive unspecified)
        ,@modus-themes-preset-overrides-faint))
(load-theme 'modus-vivendi :no-confirm)

(defun my/use-term-bg-for-frame (frame)
  "If FRAME is a terminal (tty) frame, remove theme background."
  (message "hi!")
  (with-selected-frame frame
    (unless (display-graphic-p frame)
      (set-face-attribute 'default frame :background 'unspecified)
      (redraw-frame frame)
      )))

; (add-hook 'after-make-frame-functions #'my/use-term-bg-for-frame)

;; Call dired with some useful switches.
(use-package dired
  :config
  (require 'dired-x)
  (put #'dired-find-alternate-file 'disabled nil)
  (setq dired-dwim-target t)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-listing-switches "-ahl")

  (setq dired-omit-files
        (rx (or (seq bol (? ".") "#")         ; Emacs #autosave files
                (seq bol "." (not (any "."))) ; .dotfiles
                (seq "~" eol))))              ; backup~ files

  (defun my/dired-toggle-hidden ()
    "Toggle display of hidden files."
    (interactive)
    (if dired-omit-mode
        (dired-omit-mode -1)
      (dired-omit-mode +1)))

  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . dired-omit-mode))

  :bind
  ((:map dired-mode-map
         (("C-."   . my/dired-toggle-hidden)
          ("C-c i" . image-dired)))))

(use-package dired-filter
  :after dired
  :ensure t
  :bind
  ((:map dired-mode-map
         ("C-c /" . dired-filter-mode))))

;; Use Emacs' new fancy tab bar.
(use-package tab-bar
  :config
  (setq tab-bar-show 1)
  (setq tab-bar-separator "")
  (setq tab-bar-auto-width nil)
  (setq tab-bar-tab-hints t)
  (setq tab-bar-close-button-show nil)
  (setq tab-bar-select-tab-modifiers '(meta))
  (setq tab-bar-format
        '(tab-bar-format-tabs-groups tab-bar-format-align-right))

  (defun my/tab-bar-tab-name-format (tab i)
    (let ((current-p (eq (car tab) 'current-tab)))
      (propertize
       (concat
        (if tab-bar-tab-hints (format " %d" i) " ")
        (format " %s" (alist-get 'name tab))
        (or (and tab-bar-close-button-show
                 (not (eq tab-bar-close-button-show
                          (if current-p 'non-selected 'selected)))
                 tab-bar-close-button)
            " "))
       'face (funcall tab-bar-tab-face-function tab))))

  (defun my/tab-bar-tab-group-format (tab i &optional current-p)
    (propertize
     (concat (if (and tab-bar-tab-hints (not current-p)) (format " [%s " i) " ")
             (funcall tab-bar-tab-group-function tab)
             (if (and tab-bar-tab-hints (not current-p)) "] " ":"))
     'face (if current-p 'tab-bar-tab-group-current 'tab-bar-tab-group-inactive)))

  (setq tab-bar-tab-name-format-function  #'my/tab-bar-tab-name-format)
  (setq tab-bar-tab-group-format-function #'my/tab-bar-tab-group-format)

  (defun my/tab-group-from-project ()
    "Call `tab-group` with the current project name as the group."
    (interactive)
    (when-let* ((proj (project-current))
                (name (file-name-nondirectory
                       (directory-file-name (project-root proj)))))
      (tab-group (format "%s" name))))

  (bind-key "C-x t P" #'my/tab-group-from-project)

  (tab-bar-mode +1)
  (tab-bar-history-mode +1)

  :bind
  (("C-c ]" . tab-next)
   ("C-c [" . tab-previous)
   (:repeat-map my/tab-repeat-map
                (("]" . tab-next)
                 ("[" . tab-previous)))))

;; Buffer handling.
(use-package ibuffer
  :custom
  (ibuffer-never-show-predicates
   ;; Hide all aux buffers except *scratch*.
   '((lambda (buffer)
       (let ((bufname (buffer-name buffer)))
         (and (not (string= "*scratch*" bufname))
              (string-match-p (rx line-start "*" (one-or-more any) "*" line-end) bufname)))))))

(use-package ibuffer-project
  :ensure t
  :hook
  ((ibuffer .  (lambda ()
                 (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
                 (unless (eq ibuffer-sorting-mode 'project-file-relative)
                   (ibuffer-do-sort-by-project-file-relative))))))

(use-package activities
  :ensure t
  :init
  (activities-mode +1)
  ;; Prevent `edebug' default bindings from interfering.
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  :bind
  (("C-x C-a C-n" . activities-new)
   ("C-x C-a C-d" . activities-define)
   ("C-x C-a C-a" . activities-resume)
   ("C-x C-a C-s" . activities-suspend)
   ("C-x C-a C-k" . activities-kill)
   ("C-x C-a RET" . activities-switch)
   ("C-x C-a b"   . activities-switch-buffer)
   ("C-x C-a g"   . activities-revert)
   ("C-x C-a l"   . activities-list)))

(use-package prog-mode
  :config
  ;; Show line numbers in prog modes.
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  ;; Replace `lambda' with an actual lambda symbol in Lisp modes.
  (add-hook 'emacs-lisp-mode-hook #'prettify-symbols-mode)
  (add-hook 'lisp-mode-hook #'prettify-symbols-mode))

(use-package conf-mode
  :config
  ;; Show line numbers in conf modes.
  (add-hook 'conf-mode-hook #'display-line-numbers-mode))

;; Vertico is the superior completion framework. Unlike Ivy it uses all the
;; built-in functionality from Emacs, is light on resources, and much easier to
;; customize.
(use-package vertico
  :ensure t
  :init
  (vertico-mode +1)
  (setq vertico-cycle t)
  :bind ((:map vertico-map
               ("C-h h" . minibuffer-completion-help))))

(use-package vertico-repeat
  :after vertico
  :hook
  ((minibuffer-setup . vertico-repeat-save))
  :bind
  (("C-x ." . vertico-repeat)))

(use-package vertico-directory
  :after vertico
  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :bind
  ((:map vertico-map
         ("<return>" . vertico-directory-enter)
         ("RET"      . vertico-directory-enter)
         ("DEL"      . vertico-directory-delete-char)
         ("M-DEL"    . vertico-directory-delete-word))))

;; Additional info like previews and docstrings for Vertico completions.q
(use-package marginalia
  :ensure t
  :after vertico
  :init
  (marginalia-mode +1))

;; More useful Vertico commands.
(use-package consult
  :ensure t
  :after vertico
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0.75)
  (setq register-preview-function #'consult-register-format)
  (setq xref-show-xrefs-function #'consult-xref)
  (setq xref-show-definitions-function #'consult-xref)

  ;; Override with consult functions.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Include theme-hook into consult-theme.
  (advice-add #'consult-theme :after (lambda (&rest _) (run-hooks 'my/after-load-theme-hook)))

  ;; Allow searching hidden folders (for dotfiles), but ignore git folder.
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator /\
   --smart-case --no-heading --with-filename --line-number --search-zip --hidden -g !.git/")

  (defun my/consult-ripgrep-from-isearch ()
    "Turn current isearch into a project-wide search using `consult-ripgrep'."
    (interactive)
    (let ((query (if isearch-regexp isearch-string (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (let ((search-nonincremental-instead))
        (ignore-errors (isearch-done t t)))
      (consult-ripgrep nil query)))

  (defun my/consult-line-from-isearch ()
    "Invoke `consult-line' on the results from the current isearch."
    (interactive)
    (let ((query (if isearch-regexp isearch-string (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (let ((search-nonincremental-instead))
        (ignore-errors (isearch-done t t)))
      (consult-line query)))

  (defun my/consult-flymake-project ()
    "Show all eglot diagnostics from the current project.
If not inside a project, use the current file or cwd instead."
    (interactive)
    (consult-flymake (eglot--current-project)))

  :bind
  (("M-y"     . consult-yank-pop)
   ("M-X"     . consult-mode-command)
   ("C-x B"   . consult-bookmark)
   ;; LSP specific -- therefore in C-c namespace
   ("C-c d"   . consult-flymake)
   ("C-c D"   . my/consult-flymake-project)
   ;; M-s - Search bindings
   ("M-s M-s" . consult-ripgrep)
   ("M-s s"   . consult-isearch-history)
   ("M-s i"   . consult-info)
   ;; M-g - Go bindings
   ("M-g M-g" . consult-line)
   ("M-g a"   . consult-org-agenda)
   ("M-g m"   . consult-mark)
   ("M-g M-m" . consult-global-mark)
   ("M-g i"   . consult-imenu)
   ("M-g o"   . consult-outline)
   ("M-g r"   . consult-register)
   ;; Remap bingings
   ([remap goto-line]                     . consult-goto-line)
   ([remap recentf]                       . consult-recent-file)
   ([remap switch-to-buffer]              . consult-buffer)
   ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
   ([remap switch-to-buffer-other-frame]  . consult-buffer-other-frame)
   ([remap project-switch-to-buffer]      . consult-project-buffer))
  ;; Mode specific bindings
  (:map isearch-mode-map
        (("M-s M-s" . my/consult-ripgrep-from-isearch)
         ("M-g M-g" . my/consult-line-from-isearch))))

;; Dispatch actions for Vertico.
(use-package embark
  :ensure t
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :hook
  (embark-collect-mode . embark-collect-direct-action-minor-mode)

  :bind
  (("M-;"   . embark-act)
   ("M-/"   . embark-dwim)
   ("C-h B" . embark-bindings)
   ("C-x K" . embark-kill-buffer-and-window)
   (:map vertico-map
         (("M-q" . embark-export))))

  :config
  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
        (which-key--show-keymap
         (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "..." "")))
         (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
         nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read
prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (ignore embark-indicators)
      (apply fn args)))

(advice-add #'embark-completing-read-prompter
            :around #'embark-hide-which-key-indicator)

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Allow exporting grep or rg results as a grep buffer.
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Editable grep buffers
(use-package wgrep
  :ensure t
  :config
  (setq wgrep-enable-key "r"))

;; Better completion style -- multiple regexps in any order!
(use-package orderless
  :ensure t
  :config
  (defun orderless-fast-dispatch (word index total)
    "Match strings of length 2 or 1 literal before invoking orderless."
    (and (= index 0) (= total 1) (length< word 3)
         `(orderless-regexp . ,(concat "^" (regexp-quote word)))))

  (orderless-define-completion-style orderless-fast
    (orderless-style-dispatchers '(orderless-fast-dispatch orderless-affix-dispatch))
    (orderless-matching-styles '(orderless-literal orderless-prefixes orderless-initialism)))

  :custom
  (completion-styles '(orderless-fast substring basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-component-separator 'orderless-escapable-split-on-space))

;; Open some buffers in popups by default.
(use-package popper
  :ensure t
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          "^\\*.*-?eshell.*"
          help-mode
          eat-mode
          eshell-mode
          eat-eshell-mode
          shell-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1)
  :custom
  (popper-mode-line '(:eval (propertize " POP " 'face 'mode-line-emphasis))))

;; Popup completion
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode +1)

  :config
  (defun my/corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer if `completion-at-point' is bound."
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'my/corfu-enable-in-minibuffer)

  (setq corfu-cycle t)
  (setq corfu-auto nil)
  (setq corfu-auto-prefix 3)
  (setq corfu-min-width 20)
  (setq corfu-count 24)
  (setq corfu-auto-delay 0.2)
  (setq corfu-quit-at-boundary 'separator)
  (setq corfu-quit-no-match 'separator)
  (setq corfu-preview-current 'insert)
  (setq corfu-preselect 'prompt)

  :bind
  (:map corfu-map
        ("C-SPC" . corfu-insert-separator)))

(use-package corfu-terminal
  :ensure t
  :after corfu
  :unless (display-graphic-p)
  :config
  (corfu-terminal-mode +1))

(use-package corfu-echo
  :after corfu
  :custom
  (corfu-echo-delay '(0.5 . 0.25))
  :init
  (corfu-echo-mode +1))

(use-package corfu-history
  :after corfu
  :init
  (corfu-history-mode +1))

;; Icons
(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :after dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :after marginalia
  :ensure t
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :after corfu
  :ensure t
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-ibuffer
  :ensure t
  :hook
  (ibuffer-mode . nerd-icons-ibuffer-mode))

;; Highlight todos in comments.
(use-package hl-todo
  :ensure t
  :config
  (setq hl-todo-highlight-punctuation ":")
  (global-hl-todo-mode))

;; Better help buffers.
(use-package helpful
  :ensure t
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :bind
  (("C-h C-k" . helpful-at-point)
   ;; Overwrite some of the default commands.
   ([remap describe-command]  . helpful-command)
   ([remap describe-key]      . helpful-key)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-symbol]   . helpful-symbol)
   ([remap describe-function] . helpful-callable)))

(use-package help-at-pt
  :custom
  (help-at-pt-display-when-idle t)
  (help-at-pt-timer-delay 0.5))

;; Helpful hints about available keybindings.
(use-package which-key
  :ensure t
  :config
  (which-key-mode +1)
  (setq which-key-idle-delay 0.5))
;;; Keybindings
(require 'bind-key)

;; Make ESC work as a get-out button (C-g alternative).
(bind-key "<escape>" #'keyboard-escape-quit)

;; Quick buffer switching
(bind-key "C-M-l" #'mode-line-other-buffer)

;; Useful f-keys.
(bind-key "<f5>" #'eshell)
(bind-key "<f6>" #'ansi-term)
(bind-key "<f8>" #'display-fill-column-indicator-mode)
(bind-key "<f9>" #'compile)
(bind-key "C-<f9>" #'recompile)

(defun my/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.
Stolen from Prot. :)

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p) (keyboard-quit))
   ((derived-mode-p 'completion-list-mode) (delete-completion-window))
   ((> (minibuffer-depth) 0) (abort-recursive-edit))
   (t (keyboard-quit))))
(bind-key "C-g" #'my/keyboard-quit-dwim)

(define-key global-map (kbd "C-g") #'my/keyboard-quit-dwim)

(defun my/keybord-escape-quit-dont-close-splits (old-fn &rest args)
  "Temporarily override `buffer-quit-function' while applying ARGS to OLD-FN.
Meant to use as an advice to `keyboard-escape-quit'."
  (let ((buffer-quit-function #'ignore))
    (apply old-fn args)))

(advice-add #'keyboard-escape-quit :around #'my/keybord-escape-quit-dont-close-splits)

;; Marking.
(bind-key "C-c SPC" #'set-rectangular-region-anchor)
(bind-key "C-c RET" #'mark-sexp)

;; Aligning.
(bind-key "C-c -" #'align-regexp)

;; Replace list-buffer with ibuffer.
(bind-key "C-x C-b" #'ibuffer)

;; Userful list navigation
(bind-key "M-u" #'up-list)

;; Some small helper functions ...
(defun my/narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first. Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed."
  (interactive "P")
  (cond
   ;; Widen when narrowed (unless called with prefix).
   ((and (buffer-narrowed-p) (not p))
    (widen))
   ;; With active region, narrow to that.
   ((region-active-p)
    (narrow-to-region (region-beginning) (region-end)))
   ;; In org-mode, use some hacks to narrow to source block
   ;; or subtree.
   ((derived-mode-p 'org-mode)
    (cond ((ignore-errors (org-narrow-to-block) t))
          (t (org-narrow-to-subtree))))
   ;; In LaTeX, narrow to environment.
   ((derived-mode-p 'latex-mode)
    (LaTeX-narrow-to-environment))
   ;; Otherwise just narrow to defun at point.
   (t (narrow-to-defun))))

(defun my/narrow-to-indirect-buffer ()
  "Like `my/narrow-or-widen-dwim', but display it in an indirect buffer."
  (interactive)
  (let ((new-name (format "*%s (narrowed)*" (file-name-nondirectory buffer-file-name))))
    (clone-indirect-buffer-other-window new-name t)
    (my/narrow-or-widen-dwim nil)))

(bind-key* "C-x n" #'my/narrow-or-widen-dwim)
(bind-key* "C-x N" #'my/narrow-to-indirect-buffer)

;;; Workflow
;; Eshell
(use-package eshell
  :hook
  ((eshell-directory-change . my/eshell-sync-buffer-name)
   (eshell-mode . my/eshell--setup-keybindings)
   (eshell-mode
    . (lambda ()
        (setq-local outline-regexp eshell-prompt-regexp)
        (setq-local completion-at-point-functions
                    '(pcomplete-completions-at-point cape-file cape-history t)))))

  :init
  (defun my/eshell-sync-buffer-name ()
    "Update eshell buffer to show project and directory path."
    (let ((dirname (file-name-nondirectory (directory-file-name default-directory))))
      (if (project-current)
          (rename-buffer (format "%s %s" (project-prefixed-buffer-name "eshell") dirname))
        (rename-buffer (format "*eshell* %s" dirname)))))

  (defun my/eshell--setup-keybindings ()
    "Setup keybindings for eshell.
This somehow does not work with `:bind', so here we are."
    (require 'bind-key)
    (bind-key "M-r" #'consult-history eshell-hist-mode-map))

  :config
  (require 'em-alias)
  (defalias 'em #'find-file)
  (eshell/alias "clear" "clear t")
  (eshell/alias "ll" "ls -la")
  (eshell/alias "la" "ls -a")

  :custom
  (eshell-scroll-to-bottom-on-input t))

;; Better terminal emulation with eat
(use-package eat
  :ensure t
  :custom
  (eat-kill-buffer-on-exit t)
  :bind
  (("<f6>" . eat))
  :config
  ;; Enable eshell integration
  (eat-eshell-mode +1)
  (setq eshell-visual-commands nil)
  ;; Add `popper-cycle' (M-`) and tab commands to non-bound keys.
  (dolist (key `([?\e ?\`] [?\e ?\[] [?\e ?\]]))
    (add-to-list 'eat-semi-char-non-bound-keys key))
  (eat-update-semi-char-mode-map)
  (eat-reload))

;; Use ripgrep for grep-find
(use-package grep
  :config
  (when (executable-find "rg")
    (grep-apply-setting
     'grep-find-command
     '("rg -n -H --hidden -g '!.git/' --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 48)))
  :bind
  (("C-x C-z" . grep-find)))

;; Folding
(use-package hideshow
  :hook
  (prog-mode . hs-minor-mode)
  :bind
  (:map hs-minor-mode-map
        ("C-c TAB" . hs-toggle-hiding)))

;; Easy select a region and operate on it.
(use-package expand-region
  :ensure t
  :bind
  (("M-j" . er/expand-region))
  :config
  (setq expand-region-smart-cursor t)
  (setq expand-region-fast-keys-enabled t)
  (setq expand-region-autocopy-register "e")
  (setq expand-region-contract-fast-key "k"))

;; Quick navigation.
(use-package avy
  :ensure t
  :config
  (defun my/avy-action-exchange (pt)
    "Exchange sexps at PT and point."
    (set-mark pt)
    (transpose-sexps 0))

  (defun my/avy-action-embark (pt)
    "Act on sexp at PT with `embark-act'."
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window (cdr (ring-ref avy-ring 0))))
    t)

  (add-to-list 'avy-dispatch-alist '(?T . avy-action-teleport))
  (add-to-list 'avy-dispatch-alist '(?c . avy-action-copy))
  (add-to-list 'avy-dispatch-alist '(?E . my/avy-action-exchange))
  (add-to-list 'avy-dispatch-alist '(?. . my/avy-action-embark))

  :custom
  (avy-timeout-seconds 0.25)
  (avy-keys '(?t ?n ?s ?e ?r ?i ?a ?o ?d ?h ?g ?m ?p ?l ?f ?u))
  (avy-background t)
  (avy-style 'de-bruijn)
  (avy-orders-alist '((avy-goto-char-timer . avy-order-closest)))

  :bind
  (("M-'"     . avy-goto-char-timer)
   ("C-'"     . avy-goto-char-timer)
   ("M-\""    . avy-pop-mark)
   ("C-\""    . avy-pop-mark)
   ("M-s M-p" . avy-prev)
   ("M-s M-n" . avy-next)
   (:repeat-map my/avy-repeat-map
                (("M-n" . avy-next)
                 ("M-p" . avy-prev)))
   (:map isearch-mode-map
         (("M-'" . avy-isearch)
          ("C-'" . avy-isearch)))))

(use-package ace-window
  :ensure t
  :bind
  (("M-o" . ace-window)))

(use-package isearch
  :bind
  ((:map isearch-mode-map
         (("C-t" . isearch-forward-symbol-at-point)
          ("C-o" . isearch-occur)))))

;; Multi-cursor mode
(use-package multiple-cursors
  :ensure t
  :requires region-bindings-mode
  :bind
  (("C-c C-n" . mc/mark-next-like-this)
   ("C-c C-p" . mc/mark-previous-like-this)
   (:repeat-map my/mc-repeat-map
                (("C-n" . mc/mark-next-like-this)
                 ("C-p" . mc/mark-previous-like-this)
                 ("C-d" . mc/unmark-next-like-this)
                 ("C-h" . mc/unmark-previous-like-this)
                 ("M-n" . mc/skip-to-next-like-this)
                 ("M-p" . mc/skip-to-previous-like-this)))
   (:map region-bindings-mode-map
         (("C-c C-c" . mc/edit-lines)
          ("C-c C-r" . mc/mark-all-in-region)
          ("C-c C-f" . mc/mark-all-in-region-regexp)
          ("C-c C-a" . mc/mark-all-like-this-dwim)))
   (:map mc/keymap
         (("<escape>" . mc/keyboard-quit)))))

;; Spelling, thesaurus, etc.
(use-package jinx
  :ensure t
  :hook
  ((text-mode . jinx-mode)
   (org-mode  . jinx-mode))
  :bind
  ((:map jinx-mode-map
          (("C-x ," . jinx-correct)
          ("C-,"    . jinx-correct)
          ("M-n"    . jinx-next)
          ("M-p"    . jinx-previous)))))

(use-package define-word
  :ensure t
  :bind
  (("C-c w w" . define-word-at-point)))

(use-package mw-thesaurus
  :ensure t
  :commands mw-thesaurus-lookup-dwim
  :bind
  (("C-c w t" . mw-thesaurus-lookup-dwim)))

;;; Development
(use-package eglot
  :bind
  ((:map eglot-mode-map
         (("C-c C-a" . eglot-code-actions)
          ("C-c C-r" . eglot-rename)
          ("C-c C-=" . my/eglot-format-region-or-buffer))))

  :config
  (fset #'jsonrpc--log-event #'ignore)
  (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider)

  (defun my/eglot-format-region-or-buffer ()
    "Formats the current selected region or buffer if no region is selected."
    (interactive)
    (if (region-active-p)
        (call-interactively #'eglot-format)
      (call-interactively #'eglot-format-buffer)))

  (defun my/vue-eglot-init-options ()
    (let ((tsdk-path (expand-file-name
                      "lib"
                      (shell-command-to-string
                       "npm list --global --parseable typescript | head -n1 | tr -d \"\n\""))))
      `( :typescript (:tsdk ,tsdk-path)
         :vue (:hybridMode :json-false)
         :languageFeatures ( :references t
                             :implementation t
                             :definition t
                             :typeDefinition t
                             :callHierarchy t
                             :hover t
                             :rename t
                             :renameFileRefactoring t
                             :signatureHelp t
                             :codeAction t
                             :workspaceSymbol t
                             :completion ( :defaultTagNameCase "both"
                                           :defaultAttrNameCase "kebabCase"
                                           :getDocumentNameCasesRequest nil
                                           :getDocumentSelectionRequest nil)
                             :diagnostics (:getDocumentVersionRequest nil))
         :documentFeatures ( :documentFormatting ( :defaultPrintWidth 80
                                                   :getDocumentPrintWidthRequest nil)
                             :selectionRange t
                             :foldingRange t
                             :linkedEditingRange t
                             :documentSymbol t
                             :documentColor t
                             :documentColor t))))

  (add-to-list
   'eglot-server-programs
   `(vue-mode "vue-language-server" "--stdio" :initializationOptions ,(my/vue-eglot-init-options)))
  (put 'vue-mode 'eglot-language-id "vue"))

(use-package eglot-booster
  :after eglot
  :init
  (unless (package-installed-p 'eglot-booster)
    (package-vc-install
     '(eglot-booster . (:url "https://github.com/jdtsmith/eglot-booster" :branch "main"))))
  :config
  (eglot-booster-mode +1))

(use-package eldoc
  :config
  (setq eldoc-echo-area-use-multiline-p t))

(use-package add-node-modules-path
  :ensure t)

(use-package flymake
  :hook
  ((prog-mode . flymake-mode))
  :bind
  ((:map flymake-mode-map
         (("M-g M-n" . flymake-goto-next-error)
          ("M-g M-p" . flymake-goto-prev-error))))
  :custom
  (flymake-mode-line-lighter nil)
  (flymake-show-diagnostics-at-end-of-line t))

;; The best git client you've ever seen.
(use-package magit
  :ensure t
  :demand t
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (add-hook 'magit-mode-hook #'turn-on-font-lock))

;; Git status in the fringe.
(use-package diff-hl
  :ensure t
  :config
  (if (display-graphic-p)
      (fringe-mode '(2 . 2))
    (diff-hl-margin-mode))
  (global-diff-hl-mode +1)
  :custom
  (diff-hl-draw-borders nil))

;; Tree-sitter languages
(use-package treesit-auto
  :if (>= emacs-major-version 29)
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode +1))

(use-package typescript-ts-mode
  :if (>= emacs-major-version 29)
  :mode ("\\.tsx?\\'")
  :custom
  (typescript-ts-mode-indent-offset 4))

(use-package json-ts-mode
  :if (>= emacs-major-version 29)
  :custom
  (json-ts-mode-indent-offset 4))

(use-package yaml-ts-mode
  :if (>= emacs-major-version 29)
  :custom
  (yaml-ts-mode-indent-offset 2)
  (yaml-indent-offset 2))

(use-package c-ts-mode
  :if (>= emacs-major-version 29)
  :config
  (setq-default c-basic-offset 4)
  :custom
  (c-default-style "k&r")
  (c-ts-mode-indent-style 'k&r)
  (c-ts-mode-indent-offset 4))

;; LaTeX
(use-package auctex
  :ensure t
  :defer nil
  :config
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq TeX-source-correlate-start-server t)
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))

(use-package pdf-tools
  :ensure t)

;; Lisp
(use-package sly
  :ensure t
  :init
  ;; Load helper file if it exists. This is generated by roswell.
  (when (file-exists-p "~/.roswell/helper.el")
    (load (expand-file-name "~/.roswell/helper.el")))

  (setq sly-lisp-implementations
        '((sbcl    ("sbcl")           :coding-system utf-8-unix)
          (roswell ("ros" "-Q" "run") :coding-system utf-8-unix)))

  (setq inferior-lisp-program "ros -Q run")
  (setq sly-default-lisp 'roswell))

(use-package sly-mrepl
  :after sly
  :bind
  ((:map sly-mrepl-mode-map
         ([remap display-local-help] . sly-describe-symbol)
         ("M-h" . consult-history))))

(use-package paredit
  :ensure t
  :bind
  ((:map paredit-mode-map
         (("C-c '"  . paredit-splice-sexp)
          ("C-c \"" . paredit-split-sexp)
          ("C-c ;"  . paredit-comment-dwim)
          ("M-^"    . my/paredit-delete-indentation))))
  :hook
  ((emacs-lisp-mode       . enable-paredit-mode)
   (lisp-mode             . enable-paredit-mode)
   (lisp-interaction-mode . enable-paredit-mode)
   (sly-mrepl-mode        . enable-paredit-mode))

  :config
  (define-key paredit-mode-map (kbd "M-s")  nil)
  (define-key paredit-mode-map (kbd "M-S")  nil)
  (define-key paredit-mode-map (kbd "M-;")  nil)
  (define-key paredit-mode-map (kbd "M-\"") nil)

  (defun my/paredit-sly-mrepl-return ()
    "Make `paredit-RET' play nice with sly.
It calls `sly-mrepl-return' when invoked at end-of-line."
    (when
        (and (string-prefix-p "*sly-mrepl for" (buffer-name (current-buffer)))
             (= (point) (save-excursion (end-of-line) (point))))
      (sly-mrepl-return)))
  (advice-add #'paredit-RET :after #'my/paredit-sly-mrepl-return)

  (defun my/paredit-delete-indentation (&optional arg)
    "Handle joining lines that end in a comment."
    (interactive "*P")
    (let (comment)
      (save-excursion
        (move-beginning-of-line (if arg 1 0))
        ;; FIXME This misidentifies a semicolon inside a string as a comment
        ;; in lisp
        (when (skip-syntax-forward "^<" (pos-eol))
          (setq comment (delete-and-extract-region (point) (pos-eol)))))
      (delete-indentation arg)
      (when comment
        (save-excursion
          (move-end-of-line 1)
          (insert " ")
          (insert comment))))))

;; Ruby
(use-package inf-ruby
  :ensure t
  :hook
  ((ruby-mode    . inf-ruby-minor-mode)
   (ruby-ts-mode . inf-ruby-minor-mode))
  :bind
  ((:map inf-ruby-minor-mode-map
         ("C-c C-z" . run-ruby)
         ("C-c C-b" . ruby-send-block)
         ("C-c C-l" . ruby-load-file)
         ("C-c C-r" . ruby-load-current-file)
         ("C-c C-c" . ruby-send-line))))

(use-package robe
  :ensure t
  :commands (robe-start robe-mode)
  :hook
  ((ruby-mode    . robe-mode)
   (ruby-ts-mode . robe-mode)))

(use-package bundler
  :ensure t)

;; HTML / CSS
(use-package css-mode
  :custom
  (css-fontify-colors nil))

(use-package web-mode
  :ensure t
  :mode
  (("\\.html?\\'" . web-mode)
   ("\\.tpl\\'"   . web-mode)
   ("\\.vue\\'"   . vue-mode))

  :config
  (defun my/web-mode-insert-or-expand-dwim ()
    "Intelligently choose what to insert based on context.
If `emmet-mode' is active, it can expand e+ expressions too."
    (interactive)
    (if (not (and (get-text-property (point) 'tag-type)
                  (not (get-text-property (point) 'tag-beg))))
        (if mark-active
            (web-mode-surround)
          (if (and (bound-and-true-p emmet-mode)
                   (not (string-match-p "\\([[:blank:]]\\|>\\)" (char-to-string (char-before)))))
              (emmet-expand-line nil)
            (web-mode-element-insert)))
      (if (member (get-text-property (point) 'tag-type) '(start void))
          (web-mode-attribute-insert)
        (message "insert ** invalid context **"))))

  :bind
  ((:map web-mode-map
         (("C-c C-c" . my/web-mode-insert-or-expand-dwim))))

  :hook
  ((vue-mode . (lambda ()
                 ;; vue-ls does its own pairing, therefore disable it.
                 (electric-pair-local-mode -1)
                 ;; It also does its own indentation, so turn off web-mode's.
                 (setq-local web-mode-enable-auto-indentation nil))))

  :config
  (define-derived-mode vue-mode
    web-mode "Vue"
    "Web-mode derivative for Vue files.")

  :custom
  (web-mode-enable-current-column-highlight nil)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-css-colorization nil)
  (web-mode-markup-indent-offset 4)
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4)
  (web-mode-part-padding 0)
  (web-mode-script-padding 0)
  (web-mode-style-padding 0))

(use-package emmet-mode
  :ensure t
  :hook
  ((html-mode . emmet-mode)
   (css-mode  . emmet-mode)
   (web-mode  . emmet-mode)
   (vue-mode  . emmet-mode))
  :bind
  ((:map emmet-mode-keymap
         (("M-n" . emmet-next-edit-point)
          ("M-p" . emmet-prev-edit-point))))
  :config
  (setq emmet-self-closing-tag-style " /")
  (setq emmet-move-cursor-between-quotes t)
  (require 'bind-key)
  (unbind-key "C-c C-c" emmet-mode-keymap))

;; Rest Client
(use-package restclient
  :ensure t)

;; XML
(use-package nxml-mode
  :config
  (setq nxml-child-indent 4)
  (setq nxml-attribute-indent 4)
  (setq nxml-slash-auto-complete-flag t))

;; Markdown
(use-package markdown-mode
  :ensure t
  :hook
  ((markdown-mode . auto-fill-mode)
   (gfm-mode      . auto-fill-mode))

  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.mdx\\'"      . gfm-mode)
   ("\\.md\\'"       . markdown-mode)))

;; ... and everything else.
;; Packages without configuration
(use-package git-modes
  :ensure t)

(use-package graphql-mode
  :ensure t)

;;; Org-mode
(defun my/org-hook ()
  "Custom org hook to make org buffers look nice and function better."
  (let ((inhibit-message t))
    (set-fill-column 100))
  (visual-line-mode +1)
  (display-line-numbers-mode -1)
  (hl-line-mode -1)
  (diff-hl-mode -1)
  (org-cycle-hide-drawers 'all))

(defvar my/base-agenda-files '("Inbox.org" "Calendar.org")
  "List of files included in `org-agenda' by default.")

(use-package org
  :ensure t
  :pin gnu
  :hook
  ((org-mode . my/org-hook))
  :init
  (setq org-directory "~/Documents/org/")
  :config
  (require 'dash)
  (require 'ox-md)
  (require 'ox-html)

  (setq org-hide-emphasis-markers t)
  (setq org-hide-leading-stars t)
  (setq org-auto-align-tags nil)
  (setq org-startup-with-inline-images t)
  (setq org-fold-catch-invisible-edits 'show-and-error)
  (setq org-special-ctrl-a/e t)
  (setq org-insert-heading-respect-content t)
  (setq org-log-done 'time)
  (setq org-export-with-smart-quotes t)
  (setq org-pretty-entities t)
  (setq org-ellipsis nil)
  (setq org-log-into-drawer t)
  (setq org-agenda-include-diary t)
  (setq org-agenda-inhibit-startup t)

  (setq org-agenda-custom-commands
        `(("d" "Daily agenda"
           ((agenda "" ((org-agenda-span 'day)))
            (tags-todo "+PRIORITY=\"A\""
                       ((org-agenda-overriding-header "High priority items")))))
          ("u" "Untagged items"
           ((tags-todo "-{.*}"
                       ((org-agenda-overriding-header "Untagged items")))))))

  (setq org-capture-templates
        `(("t" "TODO" entry
           (file+headline ,(concat org-directory "Inbox.org") "Reminders")
           "** TODO %?\n%(when (not (string= \"\" \"%i\")) \"%i\n\")"
           :empty-lines-after 1
           :refile-targets ((nil :level . 2)))

          ("f" "TODO with file link" entry
           (file+headline ,(concat org-directory "Inbox.org") "Reminders")
           "** TODO %?\n%(when (not (string= \"\" \"%i\")) \"%i\n\")%a"
           :empty-lines-after 1
           :refile-targets ((nil :level . 2)))

          ("j" "Journal entry" entry
           (file+olp+datetree ,(concat org-directory "Journal.org.gpg"))
           "**** %<%H:%M> %?"
           :empty-lines-after 1)

          ("n" "Note" plain
           (file denote-last-path)
           #'denote-org-capture
           :no-save t :immediate-finish nil :kill-buffer t :jump-to-captured t)

          ("s" "Shopping list item" checkitem
           (file+headline ,(concat org-directory "Inbox.org") "Shopping List")
           "- [ ] %?"
           :unnarrowed t)))

  (setq org-agenda-start-with-log-mode t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-compact-blocks t)
  (setq org-agenda-include-deadlines t)
  (setq org-agenda-span 'week)
  (setq org-agenda-files my/base-agenda-files)

  :custom-face
  (org-meta-line ((t (:inherit shadow))))
  (org-ellipsis  ((t (:underline nil))))

  :bind
  (("C-c c" . org-capture)
   ("C-c a" . org-agenda)
   (:map org-mode-map
         (("M-'"     . avy-goto-char-timer)
          ("M-g M-g" . consult-org-heading)))))

(use-package olivetti
  :ensure t
  :hook
  ((org-mode . olivetti-mode)))

(use-package org-modern
  :after org
  :ensure t
  :custom
  (org-modern-star 'replace)
  (org-modern-table nil)
  :config
  (global-org-modern-mode +1))

(use-package org-transclusion
  :after org
  :ensure t
  :bind
  ((:map org-mode-map
         (("C-c n x" . org-transclusion-add)))))

(use-package denote
  :ensure t
  :custom
  (denote-directory (file-truename (concat org-directory "notes")))
  (denote-known-keywords
   '(;; Project notes
     ("pra" . "Active project")
     ("prb" . "Backlogged project")
     ("prc" . "Completed or cancelled project")
     ;; Zettelkasten-type notes
     ("flt" . "Fleeting note")
     ("lit" . "Literature (media) note")
     ("idx" . "Index note")
     ("ref" . "Reference note")
     ("per" . "Permanent note")))

  :config
  (defun my/refresh-org-agenda-files ()
    "Refresh the list of org agenda files."
    (interactive)
    (setq org-agenda-files
          (append (denote-directory-files "__pra") my/base-agenda-files)))
  (add-hook 'org-agenda-mode-hook #'my/refresh-org-agenda-files)
  (my/refresh-org-agenda-files)

  (defun my/annotate-denote-keyword-prompt (prompt-fn &rest args)
    "Annotate PROMPT-FN marginalia style."
    (let* ((completion-extra-properties
            (list
             :affixation-function
             (lambda (completions)
               (mapcar
                (lambda (k)
                  (list "\t\t" k (alist-get k (denote-keywords) nil nil #'string=)))
                completions)))))
      (apply prompt-fn args)))

  (advice-add #'denote-keywords-prompt :around #'my/annotate-denote-keyword-prompt)

  (defun my/denote-ripgrep ()
    "Search `denote-directory' with `consult-ripgrep'."
    (interactive)
    (consult-ripgrep
     denote-directory
     (when (region-active-p)
       (buffer-substring (region-beginning) (region-end)))))

  (denote-rename-buffer-mode +1)

  :bind
  (("C-c n n" . denote-open-or-create)
   ("C-c n f" . my/denote-ripgrep)
   ("C-c n d" . denote-date)
   ("C-c n t" . denote-type)))

(use-package alert
  :ensure t
  :config
  (setq alert-default-style
        (if (eq system-type 'darwin) 'osx-notifier 'notifications)))

(use-package org-alert
  :after org
  :ensure t
  :config
  (setq org-alert-interval 300)
  (setq org-alert-notify-cutoff 60)
  (setq org-alert-notify-after-event-cutoff 10)
  (org-alert-enable))

(use-package ox-koma-letter
  :after (org ox))

(use-package ox-pandoc
  :after org
  :if (executable-find "pandoc")
  :ensure t
  :config
  (add-to-list 'org-pandoc-valid-options 'from)
  (add-to-list 'org-latex-classes
               '("memoir"
                 "\\documentclass{memoir}"
                 ("\\part{%s}" . "\\part*{%s}")
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")))
  (add-to-list 'org-latex-classes
               '("altacv"
                 "\\documentclass[10pt,a4paper,ragged2e,withhyper]{altacv}"
                 ("\\cvsection{%s}" . "\\cvsection*{%s}"))))

;; Mode-line
(use-package telephone-line
  :ensure t
  :config
  (setq telephone-line-evil-use-short-tag t)
  (setq telephone-line-rhs
        '((nil telephone-line-flymake-segment telephone-line-misc-info-segment)
          (nil telephone-line-major-mode-segment)
          (accent telephone-line-airline-position-segment)))
  (setq telephone-line-primary-left-separator 'telephone-line-nil)
  (setq telephone-line-primary-right-separator 'telephone-line-nil)
  (setq telephone-line-secondary-left-separator 'telephone-line-nil)
  (setq telephone-line-secondary-right-separator 'telephone-line-nil)
  (telephone-line-mode +1))

;; Local Variables: **
;; byte-compile-warnings: (not free-vars noruntime unresolved) **
;; End: **

;;; init.el ends here
