;;; init.el --- Doom Emacs configuration entry point

(doom! :input

       :completion
       company
       vertico

       :ui
       doom
       doom-dashboard
       doom-quit
       hl-todo
       modeline
       ophints
       (popup +defaults)
       vc-gutter
       vi-tilde-fringe
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets

       :emacs
       dired
       electric
       ibuffer
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       spell
       grammar

       :tools
       (eval +overlay)
       lookup
       lsp
       magit
       make
       tree-sitter

       :os
       (:if (featurep :system 'linux) tty)

       :lang
       emacs-lisp
       markdown
       nix
       org
       sh

       :config
       (default +bindings +smartparens))
