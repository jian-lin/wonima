(setopt
 elfeed-db-directory
 (expand-file-name "elfeed/" wonima-emacs-data-directory)
 elfeed-feeds
 ;; search feeds at https://podcastindex.org/ and https://fyyd.de
 '(("https://sachachua.com/blog/category/emacs-news/feed" emacs)
   ("https://karthinks.com/tags/emacs/index.xml" emacs)
   ("https://zhangyoufu.github.io/lwn/rss.xml" news lwn) ;; lwn with paid articles delayed
   ("https://guix.gnu.org/feeds/blog.atom" guix)
   ("https://hnrss.org/frontpage?points=50&count=50" news hn)
   ("https://haskellweekly.news/newsletter.atom" news haskell)
   ("https://feeds.buzzsprout.com/1817535.rss" haskell podcast) ;; the haskell interlude
   ("https://disroot.org/blog.atom")
   ("https://www.haskellforall.com/feeds/posts/default" haskell)
   ("https://trofi.github.io/feed/rss.xml" c nix)
   ("https://emacsredux.com/atom.xml" emacs)
   ("https://protesilaos.com/codelog.xml" emacs)
   ("https://blog.rust-lang.org/feed.xml" rust)
   ("https://rustacean-station.org/podcast.rss" rust podcast)))

(when wonima-main-emacs-instance-flag
  (run-with-idle-timer (* 60 60 2) t #'elfeed-update))
