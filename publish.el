(require 'ox)

(require 'htmlize)
(require 'rainbow-delimiters)
(rainbow-delimiters-mode 1)

(setq org-html-htmlize-output-type 'inline-css
      org-html-htmlize-font-prefix "org-")

(defun taingram--sitemap-dated-entry-format (entry style project)
  "Sitemap PROJECT ENTRY STYLE format that includes date."
  (cond ((not (directory-name-p entry))
	     (let* ((file entry)
		        (title (org-publish-find-title entry project))
		        (date (format-time-string "%m-%d" (org-publish-find-date entry project)))
		        (link (concat (file-name-sans-extension entry) ".html")))
	       (with-temp-buffer
             (setq file (file-relative-name file default-directory))
	         (insert (format "[[file:%s][%s ~ %s]]\n" file date title))
	         (buffer-string))))
	    ((eq style 'tree)
	     (file-name-nondirectory (directory-file-name entry)))
	    (t entry)))

;; Sort sitemap entries by the filename.
(defun oo--publish-find-date (file _)
  (string-match "[0-9]\\{4\\}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9].[0-5][0-9].[0-5][0-9]" file)
  (if-let (timestamp (match-string 0 file))
      (progn
        (encode-time (parse-time-string (string-replace "." ":" timestamp))))
    (error "No timestamp")))

(advice-add 'org-publish-find-date :override 'oo--publish-find-date)

;; The reason for keeping using the recursive directory is to preserve the same
;; structure.  As in I want the links to work in the org files as well as the
;; html files.
(setq org-publish-project-alist
      `(("index"
         :base-directory "org/"
         :base-extension "org"
         :exclude ".*"
         :include ("index.org")
         :publishing-function org-html-publish-to-html
         :publishing-directory "html/"
         :with-title nil
         :with-creator nil
         :with-date nil
         :with-author nil
         :with-toc nil
         :section-numbers nil
         :html-validation-link nil
         :time-stamp-file nil
         :html-head "<link rel=\"stylesheet\" href=\"index-style.css\" type=\"text/css\"/>")
        ("posts"
         :base-directory "org/posts/"
         :base-extension "org"
         :publishing-directory "html/"
         ;; Ignore files that start with `draft_'.
         :exclude "index\\.org$\\|sitemap\\.org$\\|draft_.+\\.org$"
         :publishing-function org-html-publish-to-html
         :recursive t
         :auto-sitemap t
         :sitemap-title "Blog Index"
         :sitemap-filename "sitemap.org"
         :sitemap-style list
         ;; I timestamp my files so this should sort them in order by creation date.
         :sitemap-sort-files anti-chronologically
         ;; :sitemap-format-entry "%d %t"
         ;; :sitemap-date-format
         :sitemap-format-entry taingram--sitemap-dated-entry-format
         :sitemap-file-entry-format "%d %t"
         ;; ----------------------------------- experimental
         :html-doctype "html5"
         :html-html5-fancy t
         :html-head-include-scripts nil
         :html-head-include-default-style nil
         :html-head "<link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\"/>"
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
        ;; ("all" :components ("posts" "static"))
        ;; ("static"
        ;;  :base-directory ,base-dir
        ;;  :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php\\|mov\\|html\\|txt\\|"
        ;;  :publishing-directory ,publish-dir
        ;;  :recursive t
        ;;  :publishing-function org-publish-attachment)
        ))

(org-publish-all 'force)
