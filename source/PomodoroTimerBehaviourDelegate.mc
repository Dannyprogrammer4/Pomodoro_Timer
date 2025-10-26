using Toybox.System;
using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Attention;

class PomodoroTimerBehaviourDelegate extends WatchUi.BehaviorDelegate {

    var _view;
    var vibeData;

    function initialize(_View as PomodoroTimerView) {
        BehaviorDelegate.initialize();
        _view = _View;
    }

    function onBack() as Lang.Boolean {
        System.println("👈 Back key pressed in behavior delegate");

        if (_view.Settings || _view.ExitApp && !_view.ExittingApp) {
            System.println("👈 Back key pressed in settings, exiting settings");
            _view.Settings = false;
            _view.ExitApp = false;
            if (_view._inProgress) {
                _view._Title.setText("Paused"); // Restore title
                _view.Pause = true;
                _view.setTimerValue(_view.LastPausedTime);
            } else {
                _view._Title.setText("Pomodoro Timer"); // Restore title
                _view.ResetTimer(); // Reset timer if not in progress
            }
            
            WatchUi.requestUpdate(); // Update the view immediately
            Attention.vibrate(vibeData);
            return true;
            
        } else if (!_view.Settings && !_view.ExitApp && !_view.ExittingApp) {
            System.println("👈 Back key pressed, showing exit confirmation");
            _view.ExitApp = true;
            return true;
        }
        return false;
    }


    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        if (Attention has :vibrate) {
            vibeData =
            [
                new Attention.VibeProfile(50, 500), // On for 0.5 seconds
            ];
        }
       

        if (keyEvent.getKey() == WatchUi.KEY_ESC) {
            Attention.vibrate(vibeData);
            return false; // Let view handle it or fallback
        }

        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            
            Attention.vibrate(vibeData);
            if (_view.Settings) {
                if (_view.ChangeSetting == 2) {
                    if (_view.HRS.equals("12 Hour")) {
                        _view.HRS = "24 Hour";
                    } else {
                        _view.HRS = "12 Hour";
                    }
                    WatchUi.requestUpdate();
                }
            } else if (_view.ExitApp) {
                if (_view.ChangeSetting == 1) {
                    _view.ExitApp = false;
                    if (_view._inProgress) {
                        _view._Title.setText("Paused"); // Restore title
                        _view.Pause = true;
                        _view.setTimerValue(_view.LastPausedTime);
                    } else {
                        _view._Title.setText("Pomodoro Timer"); // Restore title
                        _view.ResetTimer(); // Reset timer if not in progress
                    }
                    WatchUi.requestUpdate();
                } else if (_view.ChangeSetting == 2) {
                    _view.ExittingApp = true;
                    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                    WatchUi.requestUpdate();
                }
            
            } else {
                System.println("✅ SELECT button pressed");

                

                if (!_view._inProgress) {
                    _view._inProgress = true;
                    _view.Pause = false;
                    _view._skipTimer = false;
                    _view._Title.setText("Time to work!");
                    _view.SigmaTimer();
                } else if (_view._inProgress && !_view.Pause) {
                    _view.LastPausedTime = _view._currentDuration;
                    _view.Pause = true;
                    _view._Title.setText("Paused");
                    _view.setTimerValue(_view.LastPausedTime);
                    WatchUi.requestUpdate();
                } else if (_view._inProgress && _view.Pause) {
                    _view.Pause = false;
                    _view._Title.setText(_view.WorkTime ? "Time to work!" : "Break Time!");
                }
            }
            return true;
        }

        if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            
            if (!_view._inProgress && !_view.Settings && !_view.ExitApp || _view.Pause && !_view.Settings && !_view.ExitApp) {
                _view.showSettingsMenu();
                WatchUi.requestUpdate();
                
                _view.ChangeSetting = 1;
                Attention.vibrate(vibeData);
            }
            if (_view.Settings || _view.ExitApp) {
                if (_view.ChangeSetting >= 2) {
                    _view.ChangeSetting = 1;
                } else if (_view.ChangeSetting >= 1) {
                    _view.ChangeSetting++;
                }
                WatchUi.requestUpdate();
               
                System.println(_view.ChangeSetting);
            } else {
                if (_view._inProgress && !_view.Pause) {
                    _view._skipTimer = true;
                    
                } else {
                    _view._skipTimer = false;
                }
                Attention.vibrate(vibeData);
            }
            return true;
        }

        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            
            System.println("❌ UP button pressed");
            if (_view.Settings || _view.ExitApp) {
                if (_view.ChangeSetting <= 2) {
                    _view.ChangeSetting--;
                    if (_view.ChangeSetting < 1) {
                        _view.ChangeSetting = 2;
                    }
                    WatchUi.requestUpdate();
                }
            } else {
                if (!_view._inProgress) {
                    _view.changeState = !_view.changeState;
                    _view.ChangeState();
                    _view._currentDuration = _view.workDuration;
                    _view.setTimerValue(_view._currentDuration);
                    
                } else if (_view._inProgress) {
                    _view.ResetTimer();
                    
                }
                Attention.vibrate(vibeData);
            }
            return true;
        }
        

        return false;
    }
    
}
