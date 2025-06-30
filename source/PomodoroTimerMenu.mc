using Toybox.WatchUi;
using Toybox.System;

class PomodoroTimerMenuInputDelegate extends WatchUi.MenuInputDelegate {
    
    function initialize() {
        MenuInputDelegate.initialize(); // ✅ Superclass init is required
    }
}
