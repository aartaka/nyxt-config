(in-package #:nyxt-user)

;;;; This is a configuration for the Ace editor Nyxt integration
;;;; (https://github.com/atlas-engineer/nx-ace).

(define-configuration nx-ace:ace-mode
  ((nx-ace:extensions
    '("https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/keybinding-emacs.min.js"
      ;; Themes
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/theme-twilight.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/theme-github.min.js"
      ;; Language modes
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-c_cpp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-asciidoc.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-clojure.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-csharp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-css.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-diff.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-dot.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-forth.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-fsharp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-gitignore.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-glsl.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-golang.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-haskell.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-html.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-ini.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-java.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-javascript.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-json.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-jsx.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-julia.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-kotlin.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-latex.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-lisp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-lua.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-makefile.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-markdown.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-mediawiki.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-nix.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-objectivec.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-perl.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-plain_text.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-python.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-r.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-robot.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-ruby.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-rust.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-scala.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-scheme.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-sh.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-snippets.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-sql.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-svg.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-tex.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-text.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-tsx.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-typescript.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-xml.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-yaml.min.js"
      ;; Snippets
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/c_cpp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/css.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/html.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/javascript.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/json.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/latex.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/lisp.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/makefile.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/markdown.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/plain_text.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/python.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/scheme.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/snippets.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/tex.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/text.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/snippets/yaml.min.js"
      ;; Extensions
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-language_tools.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-keybinding_menu.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-modelist.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-searchbox.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-settings_menu.min.js"
      "https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-themelist.min.js"))))

(define-configuration nx-ace:ace-mode
  ((nx-ace::theme "ace/theme/twilight")
   (nx-ace::keybindings "ace/keyboard/emacs")))

(define-configuration nx-ace:ace-mode
  ((nx-ace:epilogue
    (str:concat
     (ps:ps
       (ps:chain ace (require "ace/ext/language_tools"))
       (ps:chain editor (set-option "fontSize" 18))
       (ps:chain editor (set-option "enableBasicAutocompletion" t))
       (ps:chain editor (set-option "enableSnippets" t))
       (require
        "ace/ext/modelist"
        (lambda ()
          (let ((modelist (ps:chain ace (require "ace/ext/modelist"))))
            (ps:chain editor session
                      (set-mode (ps:chain modelist
                                          (get-mode-for-path (ps:@ window location href)) mode))))))
       (ps:chain editor commands (bind-key "Shift-space" "setMark"))
       (require
        "ace/ext/settings_menu"
        (lambda ()
          (ps:chain ace (require "ace/ext/settings_menu") (init editor)))))
     ;; I've given up on this one xD
     " // add command to lazy-load keybinding_menu extension
    editor.commands.addCommand({
        name: \"showKeyboardShortcuts\",
        bindKey: {win: \"Ctrl-Alt-h\", mac: \"Command-Alt-h\"},
        exec: function(editor) {
            ace.config.loadModule(\"ace/ext/keybinding_menu\", function(module) {
                module.init(editor);
                editor.showKeyboardShortcuts()
            })
        }
    })"))))

(define-configuration nx-ace:ace-mode
  ((style (str:concat
           %slot-value%
           (theme:themed-css (theme *browser*)
             ("#kbshortcutmenu"
              :background-color theme:background
              :color theme:on-background))))
   (nx-ace::keybindings "ace/keyboard/emacs")))

(define-configuration nyxt/editor-mode::editor-buffer
  ((default-modes `(nx-ace:ace-mode ,@%slot-value%))))
