#!/bin/sh

emacs --batch --load publish.el -f org-publish-all

# rsync -e ssh -uvr html/ thomas@taingram.org:/var/www/taingram.org/html/
