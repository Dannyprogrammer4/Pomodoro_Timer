import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class PomodoroTimerDelegate extends WatchUi.InputDelegate {

    var _view;

    function initialize(view as PomodoroTimerView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            System.println("✅ SELECT button pressed");

            if (!_view._inProgress) {
                _view._inProgress = true;
                _view.SigmaTimer();
            } else if (_view._inProgress) {
                _view.stopTimer();
                _view._inProgress = false;
            }
            return true;
        }

        if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            System.println("❌ BACK button pressed");
            if (_view._inProgress) {
                _view._skipTimer = true;
            } else {
                _view._skipTimer = false;
            }
            return true;
        }

        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            System.println("❌ UP button pressed");
            if (_view.changeState) {
                _view.changeState = false;
            } else if (!_view.changeState) {
                _view.changeState = true;
            }
            return true;
        }

        return false;
    }
}
