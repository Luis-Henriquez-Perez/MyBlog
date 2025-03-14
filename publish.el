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
(defun oo--publish-find-date (orig-fn file project)
  (let ((timestamp nil)
        (regexp "[0-9]\\{4\\}-[01][0-9]-[0-3][0-9]T[0-2][0-9].[0-5][0-9].[0-5][0-9]"))
    (if (string-match regexp file)
        (progn (setq timestamp (match-string 0 file))
               (message "file -> %s" file)
               (encode-time (parse-time-string (string-replace "." ":" timestamp))))
      (funcall orig-fn file project))))

(advice-add 'org-publish-find-date :around 'oo--publish-find-date)

;; The reason for keeping using the recursive directory is to preserve the same
;; structure.  As in I want the links to work in the org files as well as the
;; html files.
(setq org-html-wrap-src-lines t)

(defvar oo-staples (list :with-emphasize t
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

(defun oo-publish-sitemap-default (title list)
  "Default site map, as a string.
TITLE is the title of the site map.  LIST is an internal
representation for the files to include, as returned by
`org-list-to-lisp'.  PROJECT is the current project."
  (let (posts)
    (setq posts (cl-find-if (lambda (it) (equal (car-safe it) "posts")) list))
    (setq posts (cl-second posts))
    (concat "#+TITLE: " title "\n\n" (org-list-to-org posts))))

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
         ,@oo-staples)
        ("pages"
         :base-directory "org"
         :base-extension "org"
         :publishing-directory "html"
         :recursive nil
         :exclude "index\\.org$"
         :publishing-function org-html-publish-to-html
         :html-doctype "html5"
         :html-html5-fancy t
         ,@oo-staples)
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
         ,@oo-staples)
        ("static"
         :base-directory "org"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|php\\|mov\\|html\\|txt\\|"
         :publishing-directory "html/"
         :publishing-function org-publish-attachment
         :recursive t)
        ("all" :components ("index" "posts" "pages" "static"))))

(org-publish "posts" :force)
(org-publish "pages" :force)
(org-publish "static" :force)
(org-publish "index" :force)
;; (org-publish "all" 'force)
