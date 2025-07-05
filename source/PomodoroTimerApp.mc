import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroTimerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new PomodoroTimerView();
        var behaviorDelegate = new PomodoroTimerBehaviourDelegate(view);

        return [view, behaviorDelegate];
    }


}

function getApp() as PomodoroTimerApp {
    return Application.getApp() as PomodoroTimerApp;
}
