(defconst wonima-gcs-done (- gcs-done wonima-initial-gcs-done)
  "Number of GC done during `load'ing user configuration.")
(defconst wonima-gc-elapsed (- gc-elapsed wonima-initial-gc-elapsed)
  "Time used by GC during `load'ing user configuration.")

(when wonima-profile-flag
  (declare-function profiler-stop "profiler")
  ;; `profiler-start' in prelude
  (profiler-stop))
