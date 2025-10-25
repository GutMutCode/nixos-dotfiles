;;; config.el --- Personal configuration for Doom Emacs

(setq user-full-name "gmc"
      user-mail-address "your@email.com")

(setq doom-theme 'doom-one)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")

(setq doom-font (font-spec :family "Maple Mono NF CN" :size 14))
(set-fontset-font t 'hangul (font-spec :family "S-Core Dream"))

(setq fancy-splash-image "/home/gmc/Devs/doom-emacs-splash/svg/doom/doomEmacsTokyoNight.svg")
