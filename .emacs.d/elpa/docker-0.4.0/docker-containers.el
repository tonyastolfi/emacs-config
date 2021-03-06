;;; docker-containers.el --- Emacs interface to docker-containers

;; Author: Philippe Vaucher <philippe.vaucher@gmail.com>

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:

(require 'docker-process)
(require 'docker-utils)
(require 'tablist)

(require 'magit-popup)

(defun docker-containers-entries ()
  "Return the docker containers data for `tabulated-list-entries'."
  (let* ((fmt "{{.ID}}\\t{{.Image}}\\t{{.Command}}\\t{{.RunningFor}}\\t{{.Status}}\\t{{.Ports}}\\t{{.Names}}")
         (data (docker "ps" (format "--format='%s'" fmt) "-a "))
         (lines (s-split "\n" data t)))
    (-map #'docker-container-parse lines)))

(defun docker-container-parse (line)
  "Convert a LINE from \"docker ps\" to a `tabulated-list-entries' entry."
  ;; TODO what if command contains a \t ?
  (let ((data (s-split "\t" line)))
    (list (nth 6 data) (apply #'vector data))))

(defun docker-read-container-name (prompt)
  "Read an container name using PROMPT."
  (completing-read prompt (-map #'car (docker-containers-entries))))

(defun docker-start (name)
  "Start the container named NAME."
  (interactive (list (docker-read-container-name "Start container: ")))
  (docker "start" name))

(defun docker-stop (name &optional timeout)
  "Stop the container named NAME.

TIMEOUT is the number of seconds to wait for the container to stop before killing it."
  (interactive (list (docker-read-container-name "Stop container: ") current-prefix-arg))
  (docker "stop" (when timeout (format "-t %d" timeout)) name))

(defun docker-restart (name &optional timeout)
  "Restart the container named NAME.

TIMEOUT is the number of seconds to wait for the container to stop before killing it."
  (interactive (list (docker-read-container-name "Restart container: ") current-prefix-arg))
  (docker "restart" (when timeout (format "-t %d" timeout)) name))

(defun docker-pause (name)
  "Pause the container named NAME."
  (interactive (list (docker-read-container-name "Pause container: ")))
  (docker "pause" name))

(defun docker-unpause (name)
  "Unpause the container named NAME."
  (interactive (list (docker-read-container-name "Unpause container: ")))
  (docker "unpause" name))

(defun docker-rm (name &optional force link volumes)
  "Remove the container named NAME.

With prefix argument, sets FORCE to true.

Force the removal even if the container is running when FORCE is set.
Remove the specified link and not the underlying container when LINK is set.
Remove the volumes associated with the container when VOLUMES is set."
  (interactive (list (docker-read-container-name "Delete container: ") current-prefix-arg))
  (docker "rm" (when force "-f") (when link "-l") (when volumes "-v") name))

(defun docker-inspect (name)
  "Inspect the container named NAME."
  (interactive (list (docker-read-container-name "Inspect container: ")))
  (docker "inspect" name))

(defun docker-containers-run-command-on-selection (command arguments)
  "Run a docker COMMAND on the containers selection with ARGUMENTS."
  (interactive "sCommand: \nsArguments: ")
  (--each (docker-utils-get-marked-items-ids)
    (docker command arguments it))
  (tablist-revert))

(defun docker-containers-run-command-on-selection-print (command arguments)
  "Run a docker COMMAND on the containers selection with ARGUMENTS and print"
  (interactive "sCommand: \nsArguments: ")
  (let ((buffer (get-buffer-create "*docker result*")))
    (with-current-buffer buffer
      (erase-buffer))
    (--each (docker-utils-get-marked-items-ids)
      (let ((result (docker command arguments it)))
        (with-current-buffer buffer
          (goto-char (point-max))
          (insert result))))
    (display-buffer buffer)))

(defmacro docker-containers-create-selection-functions (&rest functions)
  `(progn ,@(--map
             `(defun ,(intern (format "docker-containers-%s-selection" it)) ()
                ,(format "Run `docker-%s' on the containers selection." it)
                (interactive)
                (docker-containers-run-command-on-selection ,(symbol-name it)
                                                            (s-join " " ,(list (intern (format "docker-containers-%s-arguments" it))))))
             functions)))

(defmacro docker-containers-create-selection-print-functions (&rest functions)
  `(progn ,@(--map
             `(defun ,(intern (format "docker-containers-%s-selection" it)) ()
                ,(format "Run `docker-%s' on the containers selection." it)
                (interactive)
                (docker-containers-run-command-on-selection-print ,(symbol-name it)
                                                                  (s-join " " ,(list (intern (format "docker-containers-%s-arguments" it))))))
             functions)))

(docker-containers-create-selection-functions start stop restart pause unpause rm)

(docker-containers-create-selection-print-functions inspect logs)

(docker-utils-define-popup docker-containers-inspect-popup
  "Popup for inspecting containers."
  'docker-containers-popups
  :man-page "docker-inspect"
  :actions  '((?I "Inspect" docker-containers-inspect-selection)))

(docker-utils-define-popup docker-containers-logs-popup
  "Popup for showing containers logs."
  'docker-containers-popups
  :man-page "docker-logs"
  :actions  '((?L "Logs" docker-containers-logs-selection)))

(docker-utils-define-popup docker-containers-start-popup
  "Popup for starting containers."
  'docker-containers-popups
  :man-page "docker-start"
  :actions  '((?S "Start" docker-containers-start-selection)))

(docker-utils-define-popup docker-containers-stop-popup
  "Popup for stoping containers."
  'docker-containers-popups
  :man-page "docker-stop"
  :options '((?t "Timeout" "-t "))
  :actions '((?O "Stop" docker-containers-stop-selection)))

(docker-utils-define-popup docker-containers-restart-popup
  "Popup for restarting containers."
  'docker-containers-popups
  :man-page "docker-restart"
  :options '((?t "Timeout" "-t "))
  :actions '((?R "Restart" docker-containers-restart-selection)))

(docker-utils-define-popup docker-containers-pause-popup
  "Popup for pauseing containers."
  'docker-containers-popups
  :man-page "docker-pause"
  :actions  '((?P "Pause" docker-containers-pause-selection)
              (?U "Unpause" docker-containers-unpause-selection)))

(docker-utils-define-popup docker-containers-rm-popup
  "Popup for removing containers."
  'docker-containers-popups
  :man-page "docker-rm"
  :switches '((?f "Force" "-f")
              (?v "Volumes" "-v"))
  :actions  '((?D "Remove" docker-containers-rm-selection)))

(defun docker-containers-refresh ()
  "Refresh the containers list."
  (setq tabulated-list-entries (docker-containers-entries)))

(defvar docker-containers-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "I" 'docker-containers-inspect-popup)
    (define-key map "L" 'docker-containers-logs-popup)
    (define-key map "S" 'docker-containers-start-popup)
    (define-key map "O" 'docker-containers-stop-popup)
    (define-key map "R" 'docker-containers-restart-popup)
    (define-key map "P" 'docker-containers-pause-popup)
    (define-key map "D" 'docker-containers-rm-popup)
    map)
  "Keymap for `docker-containers-mode'.")

;;;###autoload
(defun docker-containers ()
  "List docker containers."
  (interactive)
  (docker-utils-pop-to-buffer "*docker-containers*")
  (docker-containers-mode)
  (tablist-revert))

(defalias 'docker-ps 'docker-containers)

(define-derived-mode docker-containers-mode tabulated-list-mode "Containers Menu"
  "Major mode for handling a list of docker containers."
  (setq tabulated-list-format [("Id" 16 t)("Image" 15 t)("Command" 30 t)("Created" 15 t)("Status" 20 t)("Ports" 10 t)("Names" 10 t)])
  (setq tabulated-list-padding 2)
  (setq tabulated-list-sort-key (cons "Image" nil))
  (add-hook 'tabulated-list-revert-hook 'docker-containers-refresh nil t)
  (tabulated-list-init-header)
  (tablist-minor-mode))

(provide 'docker-containers)

;;; docker-containers.el ends here
