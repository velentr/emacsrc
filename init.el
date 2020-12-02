;;; init.el --- emacs configuration

;;; Commentary:

;;; Code:

(push "~/src/kernel-mode" load-path)
(push "~/src/aircam-mode" load-path)

;; quality of life improvements
(setq create-lockfiles nil)
(setq make-backup-files nil)
(setq auto-save-default nil)
(menu-bar-mode -1)
(global-linum-mode t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)

(defun sane-c-mode ()
  "Set up sane settings for editing c code."
  (c-set-style "linux")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (set-fill-column 80))
(add-hook 'c-mode-hook 'sane-c-mode)

(defun sane-elisp-mode ()
  "Sane defaults for elisp."
  (setq indent-tabs-mode nil)
  (set-fill-column 80))
(add-hook 'emacs-lisp-mode-hook 'sane-elisp-mode)

;; emacs only defines 8 colors by default; define the other 8 using solarized
;; colors
(tty-color-define "brightblack"    8 '(  0  43  54))
(tty-color-define "brightred"      9 '(203  75  22))
(tty-color-define "brightgreen"   10 '( 88 110 117))
(tty-color-define "brightyellow"  11 '(101 123 131))
(tty-color-define "brightblue"    12 '(131 148 150))
(tty-color-define "brightmagenta" 13 '(108 113 196))
(tty-color-define "brightcyan"    14 '(147 161 161))
(tty-color-define "brightwhite"   15 '(253 246 227))


(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized")
(load-theme 'solarized t)
(set-terminal-parameter nil 'background-mode 'dark)
(enable-theme 'solarized)

(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

(require 'evil)
(evil-mode 1)

;; leader commands
(defvar leader-map (make-sparse-keymap)
  "Keymap for leader sequences.")
(define-key evil-motion-state-map " " leader-map)
;; find tags
(define-key leader-map "t" #'xref-find-definitions)
(define-key leader-map "r" #'xref-pop-marker-stack)
;; scan through flycheck errors
(define-key leader-map "[" (kbd "C-c ! p"))
(define-key leader-map "]" (kbd "C-c ! n"))

;; set up editing NVIDIA's kernel sources
(require 'kernel)
(dir-locals-set-class-variables
 'nvidia-kernel
 `((nil . ((tags-table-list . ("~/src/nvidia-kernel/build/TAGS"))
           (kernel-vendor-include-path . `(,(expand-file-name "~/src/nvidia-kernel/kernel/nvgpu/include")
                                           ,(expand-file-name "~/src/nvidia-kernel/kernel/nvidia/include")))
           (kernel-arch . "arm64")
           (kernel-build-dir . ,(expand-file-name "~/src/nvidia-kernel/build"))
           (kernel-source-tree . ,(expand-file-name "~/src/nvidia-kernel/kernel/kernel-4.9"))))
   (c-mode . ((eval . (kernel-mode))))))
(dir-locals-set-directory-class "~/src/nvidia-kernel" 'nvidia-kernel)

;; set up editing aircam sources
(require 'aircam)
(dir-locals-set-class-variables
 'aircam
 `((c-mode . ((eval . (aircam-c++-mode)))) ; since emacs treats some .h as C files by default
   (c++-mode . ((eval . (aircam-c++-mode))))))
(dir-locals-set-directory-class "~/aircam" 'aircam)

;; editing sources with unicode
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
;; need to easily insert some unicode characters for eg Julia code
(defconst unicode-char-map
  '(("alpha"   . "α")
    ("beta"    . "β")
    ("Gamma"   . "Γ")
    ("gamma"   . "γ")
    ("Delta"   . "Δ")
    ("delta"   . "δ")
    ("epsilon" . "ε")
    ("Pi"      . "Π")
    ("pi"      . "π")
    ("rho"     . "ρ")
    ("Sigma"   . "Σ")
    ("sigma"   . "σ")
    ("Omega"   . "Ω")
    ("omega"   . "ω"))
  "Mapping for easier insertion of unicode characters.")
(defun unicode-name-to-char (name)
  "Convert a unicode NAME into the correct unicode character."
  (interactive (list (thing-at-point 'word 'no-properties)))
  (backward-kill-word 1)
  (insert (alist-get name unicode-char-map name nil 'equal)))
(define-key evil-insert-state-map (kbd "C-g") #'unicode-name-to-char)

;; load TAGS from cwd
(add-to-list 'tags-table-list "./TAGS")

(custom-set-variables
 ;; wtf does emacs think my terminal is light?
 '(frame-background-mode 'dark)
 '(org-startup-folded t)
 '(safe-local-variable-values
   `((kernel-source-tree . ,(expand-file-name "~/src/nvidia-kernel/kernel/kernel-4.9"))
     (kernel-build-dir . ,(expand-file-name "~/src/nvidia-kernel/build"))
     (kernel-arch . "arm64")
     (kernel-vendor-include-path . `(,(expand-file-name "~/src/nvidia-kernel/kernel/nvgpu/include")
                                     ,(expand-file-name "~/src/nvidia-kernel/kernel/nvidia/include")))
     (tags-table-list "~/src/nvidia-kernel/build/TAGS"))))

;;; init.el ends here
