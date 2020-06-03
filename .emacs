(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;(require 'package)
;(add-to-list 'package-archives
;             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;(package-initialize)

(add-to-list 'default-frame-alist '(font . "Bitstream Vera Sans Mono-12"))

(setq default-frame-alist
      '((font . "Bitstream Vera Sans Mono-12")
        (width . 260)
	(height . 83)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(column-number-mode t)
 '(custom-enabled-themes (quote (reverse)))
 '(custom-safe-themes
   (quote
    ("77515a438dc348e9d32310c070bfdddc5605efc83671a159b223e89044e4c4f1" "42142d1cb87aaca168ef08ff4cf0dac37d15ad2bac61f4f1487da8ad5378a73f" "0717ec4adc3308de8cdc31d1b1aef17dc61003f09cb5f058f77d49da14e809cf" default)))
 '(explicit-bash-args (quote ("--login" "--noediting" "-i")))
 '(js-indent-level 2)
 '(package-selected-packages
   (quote
    (cmake-mode toml-mode rust-mode rtags shackle elm-mode protobuf-mode markdown-mode yaml-mode scala-mode nose magit groovy-mode gradle-mode google-c-style git-blamed elpy dockerfile-mode docker dired-k clang-format anaconda-mode)))
 '(rtags-bury-buffer-function (quote do-not-bury-or-delete))
 '(rtags-results-buffer-other-window t)
 '(rtags-split-window-function (quote do-not-split-window))
 '(tool-bar-mode nil))

(global-set-key (kbd "C-x !") 'shell)

; ------------------------------------------------------------------------------
; Set default compilation directory to the closest git root
(defun chomp-end (str)
      "Chomp tailing whitespace from STR."
      (replace-regexp-in-string (rx (* (any " \t\n")) eos)
                                ""
                                str))
(defun compile-in-git-root ()
  (interactive)
  (let ((default-directory
          (chomp-end (shell-command-to-string "git rev-parse --show-toplevel || pwd"))))
    (call-interactively #'compile)))

(global-set-key (kbd "C-x c") 'compile-in-git-root)
;(global-set-key (kbd "C-x c") 'compile)
; ------------------------------------------------------------------------------

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(my-long-line-face ((((class color)) (:background "gray10"))) t)
 '(my-tab-face ((((class color)) (:background "grey10"))) t)
 '(my-trailing-space-face ((((class color)) (:background "gray10"))) t))


;; === Rust Stuff ======================================================
;;
(require 'rust-mode)
(add-hook 'rust-mode-hook
          (lambda () (setq indent-tabs-mode nil)))
(setq rust-format-on-save t)

;; === Gradle ==========================================================
;;
;(require 'gradle-mode)
;(gradle-mode 1)

;; === Python ==========================================================
;(require 'nose)
;(add-hook 'python-mode-hook (lambda () (nose-mode t)))

;; === Whitespace ======================================================
;; Make trailing whitespace, lines too long look very obvious.

(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
;(global-whitespace-mode t)
(global-set-key (kbd "s-SPC") 'whitespace-mode) ; shift-cmd-[spacebar]

;; === Indentation Settings ============================================

(setq-default indent-tabs-mode nil)
(add-hook 'java-mode-hook (lambda ()
			    (setq c-basic-offset 2)))
(add-hook 'python-mode-hook (lambda ()
			    (setq c-basic-offset 4)))
(add-hook 'python-mode-hook (lambda ()
			    (setq python-indent-offset 4)))
(add-hook 'javascript-mode-hook (lambda ()
                                  (setq js-indent-level 2)))
(setq c-basic-offset 4)
(setq-default c-basic-offset 4)
(setq column-number-mode t)

;; === Clang-Format ====================================================

(global-set-key (kbd "C-M-]") 'clang-format-region)
(global-set-key (kbd "C-}") 'clang-format-buffer)

; Make .h files C++ by default.
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(defun custom-cc-before-save-hook ()
  (when (or (eq major-mode 'c++-mode)
            (eq major-mode 'cc-mode)
            (eq major-mode 'c-mode))
    (clang-format-buffer)))

; (remove-hook 'before-save-hook #'clang-format-region)
; (remove-hook 'before-save-hook #'clang-format-buffer)
(add-hook 'before-save-hook #'custom-cc-before-save-hook)

; Disable minimize emacs window with the keyboard
(global-unset-key (kbd "s-m"))

; Enable spatial window navigation and prev window
(defun prev-window ()
   (interactive)
   (other-window -1))

(defun go-back ()
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(defun pin-selected-window ()
  (interactive)
  (set-window-dedicated-p (selected-window) t))

(global-set-key (kbd "C-x ,") 'go-back)
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x p") 'prev-window)
(global-set-key (kbd "C-x g") 'pin-selected-window)

; Enable yaml-mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

; Enable markdown-mode
; TODO!!


; Fix window size
(defun pin-window-size ()
  (interactive)
  (setq window-size-fixed t))

(defun unpin-window-size ()
  (interactive)
  (setq window-size-fixed nil))

(global-set-key (kbd "C-x j") 'pin-window-size)
(global-set-key (kbd "C-x J") 'unpin-window-size)

; Stop these buffers from opening new frames/windows!
(setq-default same-window-buffer-names
              '("*shell*", "*Completions*",
                "*Backtrace*", "*Buffer List*", "*scratch*", "*RTags*"))
(setq-default same-window-regexps
      '("\*Man.*\*"))
(setq-default pop-up-frames nil)
(setq-default pop-up-windows nil)
(setq pop-up-frames nil)
(setq pop-up-windows nil)

(setq split-height-threshold 4000)
(setq split-width-threshold 4000)

;; === Protobuf mode ===================================================

(require 'protobuf-mode)

(defconst my-protobuf-style
  '((c-basic-offset . 2)
    (indent-tabs-mode . nil)))

(add-hook 'protobuf-mode-hook
  (lambda () (c-add-style "my-style" my-protobuf-style t)))

;; === RTags config ====================================================

;(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
;(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)
;(add-hook 'objc-mode-hook 'rtags-start-process-unless-running)

;(defun use-rtags (&optional useFileManager)
;  (and (rtags-executable-find "rc")
;       (cond ((not (gtags-get-rootpath)) t)
;             ((and (not (eq major-mode 'c++-mode))
;                   (not (eq major-mode 'c-mode))) (rtags-has-filemanager))
;             (useFileManager (rtags-has-filemanager))
;             (t (rtags-is-indexed)))))

(define-key c-mode-base-map (kbd "M-.") (function rtags-find-symbol-at-point))
(define-key global-map      (kbd "M-.") (function rtags-find-symbol-at-point))
(define-key c-mode-base-map (kbd "M-,") (function rtags-find-all-references-at-point))
(define-key global-map      (kbd "M-,") (function rtags-find-all-references-at-point))
(define-key c-mode-base-map (kbd "M-;") (function rtags-find-file))
(define-key global-map      (kbd "M-;") (function rtags-find-file))
(define-key c-mode-base-map (kbd "C-.") (function rtags-find-symbol))
(define-key global-map      (kbd "C-.") (function rtags-find-symbol))
(define-key c-mode-base-map (kbd "C-,") (function rtags-find-references))
(define-key global-map      (kbd "C-,") (function rtags-find-references))
(define-key c-mode-base-map (kbd "C-<") (function rtags-find-virtuals-at-point))
(define-key global-map      (kbd "C-<") (function rtags-find-virtuals-at-point))
(define-key c-mode-base-map (kbd "M-i") (function rtags-imenu))
(define-key global-map      (kbd "M-i") (function rtags-imenu))
(define-key c-mode-base-map (kbd "C-x -") (function rtags-previous-match))
(define-key global-map      (kbd "C-x -") (function rtags-previous-match))
(define-key c-mode-base-map (kbd "C-x =") (function rtags-next-match))
(define-key global-map      (kbd "C-x =") (function rtags-next-match))

(define-key c-mode-base-map [s-mouse-1] (function rtags-find-symbol-at-point))
(define-key global-map      [s-mouse-1] (function rtags-find-symbol-at-point))
(define-key c-mode-base-map [S-s-mouse-1] (function rtags-find-all-references-at-point))
(define-key global-map      [S-s-mouse-1] (function rtags-find-all-references-at-point))
(define-key c-mode-base-map [M-S-mouse-1] (function rtags-find-references-at-point))
(define-key global-map      [M-S-mouse-1] (function rtags-find-references-at-point))
(define-key c-mode-base-map [C-S-mouse-1] (function rtags-find-virtuals-at-point))
(define-key global-map      [C-S-mouse-1] (function rtags-find-virtuals-at-point))

;(setq rtags-autostart-diagnostics t)

;(defun do-not-split-window (&optional window size side pixelwise) ret)
;(defun do-not-bury-or-delete () ret)

; Auto-compile config

(setq load-prefer-newer t)
(package-initialize)
(require 'auto-compile)
(auto-compile-on-load-mode)
(auto-compile-on-save-mode)

(global-set-key (kbd "C-x g") 'magit-status)


; ------------------------------------------------------------------------------
(defun timestamp ()
   (interactive)
   (insert (format-time-string "%Y-%m-%dT%H:%M:%S")))

(defun todo ()
   (interactive)
   (insert (format-time-string "TODO [tastolfi %Y-%m-%d] ")))

(global-set-key (kbd "C-c t") 'todo)

                                        ; C++ boilerplates
(defun get-class-name ()
  (read-string "Enter class name: "))

(defun start-class (name)
  (interactive)
    (c++-mode)
    (insert (concat "class " name "{public:")))  

(defun end-class ()
  (interactive)
  (insert (concat "};"))    
  (clang-format-buffer))

(defun disallow-copy (name)
  (interactive)
  (insert (concat name "(const " name " &) = delete; "
                  name "& operator=(const " name " &) = delete;")))

(defun value-type ()
  (interactive)
  (let ((name (get-class-name)))
    (start-class name)
    (end-class)))

(defun noncopyable-type ()
  (interactive)
  (let ((name (get-class-name)))
    (start-class name)
    (disallow-copy name)
    (end-class)))

(defun virtual-type ()
  (interactive)
  (let ((name (get-class-name)))
    (start-class name)
    (disallow-copy name)
    (insert (concat "\n\nvirtual ~" name "() = default;"))
    (end-class)))

(defun default-move-semantics (name)
  (interactive)
  (insert (concat name "(" name " &&) = default; "
                  name "& operator=(" name " &&) = default;")))

(defun move-only-type ()
  (interactive)
  (let ((name (get-class-name)))
    (start-class name)
    (disallow-copy name)
    (insert "\n\n")
    (default-move-semantics name)
    (end-class)))

(defun operator== ()
  (interactive)
  (let ((name (get-class-name)))
    (insert "inline bool operator==(const " name " &l, const " name " &r) { return l == r; }")
    (clang-format-buffer)))

(defun operator<< ()
  (interactive)
  (let ((name (get-class-name)))
    (insert "inline std::ostream &operator<<(std::ostream &out, const " name " &t) { return out << t; }")
    (clang-format-buffer)))

(defun hpp ()
  (interactive)
  (let ((ns (read-string "namespace: "))
        (modname (read-string "module name: ")))
    (insert "#pragma once\n"
            "#ifndef " (upcase ns) "_" (upcase modname) "_HPP\n"
            "#define " (upcase ns) "_" (upcase modname) "_HPP\n"
            "\n"
            "namespace " (downcase ns) " {\n"
            "} // " (downcase ns) "\n"
            "\n"
            "#endif // " (upcase ns) "_" (upcase modname) "_HPP\n")
        (clang-format-buffer)))

(defun test-cpp ()
  (interactive)
  (let ((ns (read-string "namespace: "))
        (modname (read-string "module name: ")))
    (insert "#include <" (downcase ns) "/" (downcase modname) ".hpp>\n"
            "//\n"
            "#include <" (downcase ns) "/" (downcase modname) ".hpp>\n"
            "\n"
            "#include <gtest/gtest.h>\n"
            "#include <gmock/gmock.h>\n"
            "\n"
            "namespace {\n"
            "\n"
            "TEST(" (capitalize modname) ", Test) {\n}\n"
            "\n"
            "} // namespace\n")
        (clang-format-buffer)))

