;;; sync-up --- Set up synchronization with vm1

;;; Commentary:
;; A file to enable setup for synchronization upon save in my local
;; Emacs.  TRAMP could be used, but for working on projects, working
;; on a local copy is really better.

;;; Code:

(when (not (fboundp 'package-installed-p))
  (package-initialize))
(when (not (package-installed-p 'auto-shell-command))
  (package-install 'auto-shell-command))

(require 'auto-shell-command)
(let ((this-dir (file-name-directory (buffer-file-name))))
  (ascmd:add
   (list this-dir
		 (concat "rsync -av --delete --exclude .git --exclude /mediawiki/images "
				 "--exclude /logs "
				 this-dir " "
				 "vm1:/home/wikipathways.org/"))))

(provide 'sync-up)
;;; sync-up ends here
