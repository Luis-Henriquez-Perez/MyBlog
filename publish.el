(require 'ox)

(require 'htmlize)

(setq org-html-htmlize-output-type 'inline-css
      org-html-htmlize-font-prefix "org-")

;; The reason for keeping using the recursive directory is to preserve the same
;; structure.  As in I want the links to work in the org files as well as the
;; html files.
(setq org-publish-project-alist
      `(("posts"
         :base-directory "org/"
         :base-extension "org"
         :publishing-directory "html/"
         ;; Ignore files that start with `draft_'.
         :exclude "draft_.+\\.org$"
         :publishing-function org-html-publish-to-html
         :recursive t
         :auto-sitemap t
         :sitemap-title "Blog Index"
         :sitemap-filename "index.org"
         :sitemap-style list
         ;; :sitemap-sort-files anti-chronologically
         ;; ----------------------------------- experimental
         :html-doctype "html5"
         :html-html5-fancy t
         :html-head-include-scripts nil
         :html-head-include-default-style nil
         :html-head "<link rel=\"stylesheet\" href=\"../style.css\" type=\"text/css\"/>"
         ;; -----------------------------------
         :with-emphasize t
         :with-footnotes t
         :with-title t
         :with-creator nil
         :with-date nil
         :with-author nil
         :with-toc nil
         :section-numbers nil
         :html-validation-link nil
         :time-stamp-file nil)
        ("static"
         :base-directory "org/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php\\|mov\\|html\\|txt\\|"
         :publishing-directory "html/"
         :publishing-function org-publish-attachment
         :recursive t)
        ("all" :components ("posts" "static"))
        ;; ("static"
        ;;  :base-directory ,base-dir
        ;;  :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php\\|mov\\|html\\|txt\\|"
        ;;  :publishing-directory ,publish-dir
        ;;  :recursive t
        ;;  :publishing-function org-publish-attachment)
        ))

(org-publish-all t)
