;;; init-minibuffer.el --- Config for minibuffer completion -*- lexical-binding: t; -*-

;; (straight-use-package '(vertico
;;                         :type git
;;                         :host github
;;                         :repo "minad/vertico"
;;                         :files ("*.el" "extensions/*.el")))
(straight-use-package 'marginalia)
(straight-use-package 'orderless)
(straight-use-package 'consult)
(straight-use-package 'embark)
(straight-use-package 'embark-consult)
(straight-use-package 'consult-dir)
(straight-use-package 'fzf)
(straight-use-package '(mct
                        :type git
                        :host gitlab
                        :repo "protesilaos/mct"))


;; orderless
(require 'prot-orderless)

(setq prot-orderless-default-styles
      '(orderless-prefixes
        orderless-regexp))
(setq prot-orderless-alternative-styles
      '(orderless-literal
        orderless-prefixes
        orderless-regexp))

(setq orderless-component-separator " +")
(setq orderless-matching-styles prot-orderless-default-styles)
(setq orderless-style-dispatchers
      '(prot-orderless-literal-dispatcher
        prot-orderless-initialism-dispatcher
        prot-orderless-flex-dispatcher))
;; SPC should never complete: use it for `orderless' groups.
(let ((map minibuffer-local-completion-map))
  (define-key map (kbd "SPC") nil)
  (define-key map (kbd "?") nil))

;; mct
;; https://gitlab.com/protesilaos/mct
;; https://protesilaos.com/emacs/dotemacs
(setq mct-remove-shadowed-file-names t)
(setq mct-completion-blocklist nil)
(setq mct-live-update-delay 0.6)
(setq mct-completion-passlist '(embark-prefix-help-command Info-goto-node Info-index Info-menu vc-retrieve-tag))

(setq completion-styles '(basic substring initials flex partial-completion orderless))
(setq completion-category-overrides '((file (styles . (basic partial-completion orderless)))))

(setq completion-pcm-complete-word-inserts-delimiters nil)
(setq completion-pcm-word-delimiters "-_./:| ")
(setq completion-ignore-case t)
(setq completions-detailed t)
(setq read-buffer-completion-ignore-case t)
(setq completion-cycle-threshold 2)
(setq completion-flex-nospace nil)
(setq completion-ignore-case t)
(setq-default case-fold-search t)

(setq completions-group t)
(setq completions-group-format
      (concat
       (propertize "    " 'face 'completions-group-separator)
       (propertize " %s " 'face 'completions-group-title)
       (propertize " " 'face 'completions-group-separator
                   'display '(space :align-to right))))

(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

(setq enable-recursive-minibuffers t)
(setq read-answer-short t)
(setq resize-mini-windows t)

(minibuffer-electric-default-mode 1)
(minibuffer-depth-indicate-mode 1)
(file-name-shadow-mode 1)

;; disable cursor movement in minibuffer
(setq minibuffer-prompt-properties
    '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(mct-minibuffer-mode 1)

;; vertico
;; (add-hook 'after-init-hook 'vertico-mode)

;; add » to indicate current candidate
;; https://github.com/minad/vertico/wiki
;; (advice-add #'vertico--format-candidate :around
;;             (lambda (orig cand prefix suffix index _start)
;;               (setq cand (funcall orig cand prefix suffix index _start))
;;               (concat
;;                (if (= vertico--index index)
;;                    (propertize "» " 'face 'vertico-current)
;;                  "  ")
;;                cand)))

;; marginalia
(setq marginalia-max-relative-age 0)
(add-hook 'after-init-hook 'marginalia-mode)

;; consult
(with-eval-after-load 'consult
  (setq consult-line-numbers-widen t
        consult-async-min-input 2
        consult-async-refresh-delay  0.15
        consult-async-input-throttle 0.2
        consult-async-input-debounce 0.1)

  (setq consult-imenu-config
        '((emacs-lisp-mode :toplevel "Functions"
                           :types ((?f "Functions" font-lock-function-name-face)
                                   (?m "Macros"    font-lock-keyword-face)
                                   (?p "Packages"  font-lock-constant-face)
                                   (?t "Types"     font-lock-type-face)
                                   (?v "Variables" font-lock-variable-name-face)))))

  (setq consult-preview-key 'any)
  (add-hook 'completion-list-mode-hook #'consult-preview-at-point-mode)

  (defmacro p-no-consult-preview (&rest cmds)
    `(with-eval-after-load 'consult
       (consult-customize ,@cmds :preview-key (kbd "M-v"))))
  (p-no-consult-preview consult-ripgrep
                        consult-git-grep
                        consult-grep
                        consult-bookmark
                        consult-recent-file
                        consult-xref
                        consult--source-file
                        consult--source-project-file
                        consult--source-bookmark
                        p-consult-rg-at-point-project
                        p-consult-rg-current-dir
                        p-consult-rg-other-dir
                        p-consult-rg-at-point-current-dir)

  (global-set-key [remap switch-to-buffer] 'consult-buffer)
  (global-set-key [remap switch-to-buffer-other-window] 'consult-buffer-other-window)
  (global-set-key [remap switch-to-buffer-other-frame] 'consult-buffer-other-frame)
  (global-set-key [remap goto-line] 'consult-goto-line)
  (global-set-key (kbd "C-x l") 'consult-line))

(autoload 'consult--grep "consult")

(defun p-consult-at-point-line (&optional initial)
  (interactive)
  (consult-line (thing-at-point 'symbol)))

(defun p-consult-rg-at-point-project (&optional dir)
  (interactive)
  (consult--grep "Ripgrep" #'consult--ripgrep-builder dir (thing-at-point 'symbol)))

(defun p-consult-rg-current-dir (&optional initial)
  (interactive "P")
  (if (equal buffer-file-name nil)
      (consult--grep "Ripgrep current dir" #'consult--ripgrep-builder "/Users/ml/" initial)
    (consult--grep "Ripgrep current dir" #'consult--ripgrep-builder (file-name-directory buffer-file-name) initial)))

(defun p-consult-rg-other-dir (&optional initial)
  (interactive "P")
  (consult--grep "Ripgrep current dir" #'consult--ripgrep-builder (read-directory-name "consult-rg directory:") initial))

(defun p-consult-rg-at-point-current-dir ()
  (interactive)
  (consult--grep "Ripgrep current dir" #'consult--ripgrep-builder (file-name-directory buffer-file-name) (thing-at-point 'symbol)))

(defun p-consult-fd-local (&optional dir initial)
  (interactive "P")
  (if (equal buffer-file-name nil)
      (consult-find "~/" initial)
    (consult-find dir initial)))

(defun p-consult-fd-global (&optional initial)
  (interactive "P")
  (consult-find (read-directory-name "consult-find directory:") initial))

;; embark
(autoload 'embark-act "embark")
(autoload 'embark-export "embark")

(global-set-key (kbd "C-,") 'embark-act)
(global-set-key (kbd "C-c C-o") 'embark-export)

;; embark action integration with which-key
(defun embark-which-key-indicator ()
  (lambda (&optional keymap targets prefix)
    (if (null keymap)
        (which-key--hide-popup-ignore-command)
      (which-key--show-keymap
       (if (eq (plist-get (car targets) :type) 'embark-become)
           "Become"
         (format "Act on %s '%s'%s"
                 (plist-get (car targets) :type)
                 (embark--truncate-target (plist-get (car targets) :target))
                 (if (cdr targets) "…" "")))
       (if prefix
           (pcase (lookup-key keymap prefix 'accept-default)
             ((and (pred keymapp) km) km)
             (_ (key-binding prefix 'accept-default)))
         keymap)
       nil nil t (lambda (binding)
                   (not (string-suffix-p "-argument" (cdr binding))))))))

(defun embark-hide-which-key-indicator (fn &rest args)
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
         (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

(advice-add #'embark-completing-read-prompter :around #'embark-hide-which-key-indicator)

(with-eval-after-load 'embark
  (setq embark-keymap-prompter-key ",")
  (setq embark-indicators '(embark-which-key-indicator embark-highlight-indicator embark-isearch-highlight-indicator))
  (add-to-list 'embark-indicators #'embark-vertico-indicator)
  (require 'embark-consult)
  (add-hook 'embark-collect-mode-hook 'embark-consult-preview-minor-mode)
  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator)))

;; keystrokes feedback interval
(setq echo-keystrokes 0.02)

;; hrm
(defvar hrm-notes-category 'hrm-note
  "Category symbol for the notes in this package.")

(defvar hrm-notes-history nil
  "History variable for hrm-notes.")

(defvar hrm-notes-sources-data
  '(("literature" ?l "~/Dropbox/literature/")))

(autoload 'consult--multi "consult")

(defun hrm-annotate-note (name cand)
  "Annotate file CAND with its source name, size, and modification time."
  (let* ((attrs (file-attributes cand))
         (fsize (file-size-human-readable (file-attribute-size attrs)))
         (ftime (format-time-string "%b %d %H:%M" (file-attribute-modification-time attrs))))
    (put-text-property 0 (length name) 'face 'marginalia-type name)
    (put-text-property 0 (length fsize) 'face 'marginalia-size fsize)
    (put-text-property 0 (length ftime) 'face 'marginalia-date ftime)
    (format "%15s  %7s  %10s" name fsize ftime)))

(defun hrm-notes-make-source (name char dir)
  "Return a notes source list suitable for `consult--multi'.
NAME is the source name, CHAR is the narrowing character,
and DIR is the directory to find notes. "
  (let ((idir (propertize (file-name-as-directory dir) 'invisible t)))
    `(:name     ,name
                :narrow   ,char
                :category ,hrm-notes-category
                :face     consult-file
                :annotate ,(apply-partially 'hrm-annotate-note name)
                :items    ,(lambda () (mapcar (lambda (f) (concat idir f))
                                              ;; filter files that glob *.*
                                              (directory-files dir nil "[^.].*[.].+")))
                ;; :action   ,(lambda (f) (find-file f) (markdown-mode)))))
                :action   find-file)))  ; use this if you don't want to force markdown-mode

(defun hrm-notes ()
  "Find a file in a notes directory."
  (interactive)
  (let ((completion-ignore-case t))
    (consult--multi (mapcar #'(lambda (s) (apply #'hrm-notes-make-source s))
                            hrm-notes-sources-data)
                    :prompt "Notes File: "
                    :group nil
                    :history 'hrm-notes-history)))


;; keybindings
(global-set-key (kbd "C-c C-d") 'consult-dir)
(global-set-key (kbd "C-c C-j") 'consult-dir-jump-file)
(global-set-key (kbd "C-c ,") 'mct-focus-mini-or-completions)

(with-eval-after-load 'evil
  (general-create-definer p-space-leader-def
    :prefix "SPC"
    :states '(normal visual))
  (p-space-leader-def
    "f"  '(:ignore t :which-key "file")
    "fr" '(consult-recent-file :which-key "recent file")
    "fd" '(consult-dir :which-key "find directory")
    "b"  '(:ignore t :which-key "buffer")
    "bb" '(consult-buffer :which-key "consult switch buffer")
    "bo" '(consult-buffer-other-window :which-key "open file in another window")
    ;; "e"  '(:ignore t :which-key "editing")
    ;; "er" '(vertico-repeat :which-key "vertico-repeat")
    "s"  '(:ignore t :which-key "search")
    "ss" '(consult-line :which-key "consult line")
    "sS" '(p-consult-at-point-line :which-key "consult at-point line")
    "sm" '(consult-multi-occur :which-key "consult multi occur")
    "sp" '(consult-ripgrep :which-key "consult-rg project")
    "sP" '(p-consult-rg-at-point-project :which-key "consult-rg at-point project")
    "sd" '(p-consult-rg-current-dir :which-key "consult-rg current dir")
    "sD" '(p-consult-rg-at-point-current-dir :which-key "consult-rg at-point current dir")
    "so" '(p-consult-rg-other-dir :which-key "consult-rg other dir")
    "sf" '(p-consult-fd-global :which-key "consult-fd global files")
    "sF" '(p-consult-fd-local :which-key "consult-fd local files")
    "si" '(consult-imenu :which-key "consult imenu")
    "sl" '(consult-outline :which-key "consult outline")
    "n"  '(:ignore t :which-key "note")
    "nh" '(hrm-notes :which-key "hrm notes find")))


(provide 'init-minibuffer)
;;; init-minibuffer.el ends here
