(require 'ox)
(require 'htmlize)

(setq org-html-htmlize-output-type 'inline-css)
(setq org-html-htmlize-font-prefix "org-")

;; Sort sitemap entries by the filename.
(defun oo--publish-find-date (orig-fn file project)
  (let ((timestamp nil)
        (regexp "[0-9]\\{4\\}-[01][0-9]-[0-3][0-9]T[0-2][0-9].[0-5][0-9].[0-5][0-9]"))
    (if (string-match regexp file)
        (progn (setq timestamp (match-string 0 file))
               (encode-time (parse-time-string (string-replace "." ":" timestamp))))
      (funcall orig-fn file project))))

(advice-add 'org-publish-find-date :around 'oo--publish-find-date)

;; The reason for keeping using the recursive directory is to preserve the same
;; structure.  As in I want the links to work in the org files as well as the
;; html files.
(setq org-html-wrap-src-lines t)

(defvar oo-publish-defaults (list :with-emphasize t
                                  :html-head-include-scripts nil
                                  :html-head-include-default-style nil
                                  :html-doctype "html5"
                                  :html-html5-fancy t
                                  :with-footnotes t
                                  :with-creator nil
                                  :with-date nil
                                  :with-author nil
                                  :with-toc nil
                                  :section-numbers nil
                                  :html-validation-link nil
                                  :time-stamp-file nil))

(setq org-publish-project-alist
      `(("index"
         :base-directory "org"
         :base-extension "org"
         :exclude ".*"
         :include ("index.org")
         :recursive nil
         :publishing-directory "html"
         :publishing-function org-html-publish-to-html
         :with-title nil
         ,@oo-publish-defaults)
        ("pages"
         :base-directory "org"
         :base-extension "org"
         :publishing-directory "html"
         :recursive nil
         :exclude "index\\.org$"
         :publishing-function org-html-publish-to-html
         :html-doctype "html5"
         :html-html5-fancy t
         ,@oo-publish-defaults)
        ("posts"
         :base-directory "org/posts"
         :base-extension "org"
         :publishing-directory "html/posts"
         :recursive nil
         :exclude "sitemap\\.org$\\|draft_.+\\.org$"
         :publishing-function org-html-publish-to-html
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :html-head "<link rel=\"stylesheet\" href=\"../style.css\" type=\"text/css\"/>"
         :sitemap-sort-files anti-chronologically
         ,@oo-publish-defaults)
        ("static"
         :base-directory "org"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php\\|mov\\|html\\|txt\\|"
         :publishing-directory "html/"
         :publishing-function org-publish-attachment
         :recursive t)))

(org-publish "posts" :force)
(org-publish "pages" :force)
(org-publish "static" :force)
(org-publish "index" :force)
