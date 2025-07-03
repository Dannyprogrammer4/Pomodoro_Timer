import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Attention;
import Toybox.Application;

class PomodoroTimerDelegate extends WatchUi.InputDelegate {

    var _view;
    var vibeData;

    function initialize(view as PomodoroTimerView) {
        InputDelegate.initialize();
        _view = view;
    }

    
    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {

        if (Attention has :vibrate) {
        vibeData =
            [
                new Attention.VibeProfile(50, 500), // On for two seconds
                new Attention.VibeProfile(0, 500),  // Off for two seconds
            ];
        }
    

        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            if (_view.Settings) {
                if (_view.ChangeSetting == 1) {
                    // If in change setting mode, toggle the setting
                    if (_view.HRS.equals("12 Hour")) {
                        _view.HRS = "24 Hour";
                    } else if (_view.HRS.equals("24 Hour")) {
                        _view.HRS = "12 Hour";
                    }
                    WatchUi.requestUpdate(); // Update the view immediately
                } else if (_view.ChangeSetting == 3) {
                    // If not in change setting mode, show settings menu
                    System.exit();
                }
            } else {
                System.println("✅ SELECT button pressed");

                Attention.vibrate(vibeData);

                if (!_view._inProgress) {
                    // First-time start
                    _view._inProgress = true;
                    _view.Pause = false;
                    _view._skipTimer = false;
                    _view._Title.setText("Time to work!");
                    _view.SigmaTimer(); // Only call once when starting!
                } else if (_view._inProgress && !_view.Pause) {
                    // Pause the countdown
                    _view.Pause = true;
                    _view._Title.setText("Paused");
                } else if (_view._inProgress && _view.Pause) {
                    // Resume the countdown
                    _view.Pause = false;
                    _view._Title.setText(_view.WorkTime ? "Time to work!" : "Break Time!");
                }
            }
            

            return true;
        }


        if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            if (_view.Settings) {
                if (_view.ChangeSetting >= 1) {
                    _view.ChangeSetting++; // Toggle change setting
                    WatchUi.requestUpdate(); // Update the view immediately
                    if (_view.ChangeSetting > 3) {
                        _view.ChangeSetting = 1;
                        WatchUi.requestUpdate(); // Update the view immediately
                    }
                }
                System.println(_view.ChangeSetting);
            } else {
                if (_view._inProgress && !_view.Pause) {
                    _view._skipTimer = true;
                    Attention.vibrate(vibeData);
                } else {
                    _view._skipTimer = false;
                }
                
            }
            return true;
        }
        
        
        if (keyEvent.getKey() == WatchUi.KEY_ESC) {
            System.println("👈 ESC key opens settings menu");
            _view.showSettingsMenu(); // Call the function you just made
            Attention.vibrate(vibeData);
            return true; // Prevent app from exiting
        }







        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            System.println("❌ UP button pressed");
            if (_view.Settings) {
                 if (_view.ChangeSetting <= 3) {
                    _view.ChangeSetting--; // Toggle change setting
                    WatchUi.requestUpdate(); // Update the view immediately
                    if (_view.ChangeSetting < 1) {
                        _view.ChangeSetting = 3;
                        WatchUi.requestUpdate(); // Update the view immediately
                    }
                 }
            } else {
                if (!_view._inProgress) {
                    if (_view.changeState) {
                        _view.changeState = false;
                        _view.ChangeState(); // ✅ apply new durations
                        _view._currentDuration = _view.workDuration;
                        _view.setTimerValue(_view._currentDuration);
                        Attention.vibrate(vibeData);
                    } else {
                        _view.changeState = true;
                        _view.ChangeState(); // ✅ apply new durations
                        _view._currentDuration = _view.workDuration;
                        _view.setTimerValue(_view._currentDuration);
                        Attention.vibrate(vibeData);
                    }
                } else if (_view._inProgress) {
                    _view.ResetTimer();
                    Attention.vibrate(vibeData);
                }
                

            }
            return true;
        }

        return false;
    }
}
