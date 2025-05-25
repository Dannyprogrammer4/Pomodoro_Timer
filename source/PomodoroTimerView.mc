import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Graphics;


class PomodoroTimerView extends WatchUi.View {

    var _Title;
    var _Timer;         
    var _CurrentTime;   
    var m_Timer;       
    var _timers;       
    var _currentDuration;
    var _inProgress = false;
    var _sigma;
    var _skipTimer = false;
    var workDuration = 15;
    var breakDuration = 5;
    var changeState;
    var image;
    var customFont5;
    var customFont3;
    var customFont4;

    function initialize() {
        View.initialize();
        _sigma = true;
        changeState = false;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        customFont5 = WatchUi.loadResource(Rez.Fonts.customFont5); // ← Load font
        customFont3 = WatchUi.loadResource(Rez.Fonts.customFont3); // ← Load second font
        customFont4 = WatchUi.loadResource(Rez.Fonts.customFont4); // ← Load second font

        _Title = findDrawableById("title");
        _Timer = findDrawableById("timer");
        _CurrentTime = findDrawableById("current_time");
        image = findDrawableById("pomodoro1_icon"); 
        image.setLocation(0, 0);

        if (customFont5 != null) {
            _Title.setFont(customFont5);
            _Timer.setFont(customFont3);
            _CurrentTime.setFont(customFont4);
        } else {
            System.println("❌ Failed to load custom font!");
        }
}

    


    function onShow() as Void {
        WatchUi.requestUpdate();
        delayedStart();
        setTimerValue(workDuration);
    }

    function delayedStart() as Void {
        CurrentTime();
        updateTimer();
    }

    function updateTimer() as Void {
        m_Timer = new Timer.Timer();
        m_Timer.start(method(:Update), 1000, true);
    }

    function SigmaTimer() as Void {
        _currentDuration = workDuration;
        _timers = new Timer.Timer();
        _timers.start(method(:countDownTick), 1000, true);
        countDownTick();
    }
    function stopTimer () as Void {
        _timers.stop();
        _inProgress = false;
    }

    function Update() as Void {
        CurrentTime();
        ChangeState();
        if (_inProgress == false) {
            setTimerValue(workDuration);
        }
    }

    function ChangeState() as Void {
        if (changeState == true) {
            workDuration = 30;
            breakDuration = 10;
        } else if (changeState == false) {
            workDuration = 15;
            breakDuration = 5;
        }
    }

    function countDownTick() as Void {
        if (_currentDuration <= 0) {
            _skipTimer = true;
        }   
        if (_skipTimer == true) {
            if (_sigma == true) {
                _currentDuration = breakDuration;
                _Title.setText("Break Time!");
            } else if (_sigma == false) {
                _currentDuration = workDuration;
                _Title.setText("Time to work!");
            }
            _sigma = !_sigma;
            _skipTimer = false; 
        }

        setTimerValue(_currentDuration);
        _currentDuration--;
    }

    function setTimerValue(value) as Void {
        var minutes = value / 60;
        var seconds = value % 60;
        var secondsFormatted = seconds < 10 ? "0" + seconds.toString() : seconds.toString();
        var formattedValue = minutes.toString() + ":" + secondsFormatted;

        if (_Timer != null) {
            _Timer.setText(formattedValue);
            WatchUi.requestUpdate();
        } else {
            System.println("⚠️ _Timer is null");
        }
    }

    function CurrentTime() as Void {
        if (_CurrentTime != null) {
            var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            var hour = info[:hour];
            var minute = info[:min];

            var hourDisplay = (hour > 12) ? (hour - 12) : (hour == 0 ? 12 : hour);
            var ampm = (hour >= 12) ? "PM" : "AM";
            var minuteStr = (minute < 10) ? "0" + minute.toString() : minute.toString();
            var timeStr = hourDisplay.toString() + ":" + minuteStr + " " + ampm;

            _CurrentTime.setText(timeStr);
            WatchUi.requestUpdate();
        } else {
            System.println("⚠️ _CurrentTime is null");
        }
    }

    function onHide() as Void {
        if (m_Timer != null) {
            m_Timer.stop();
        } 
        if (_timers != null) {
             _timers.stop();
        }
    }
}
