import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Attention;
import Toybox.Application;

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
    var workDuration;
    var breakDuration;
    var changeState;
    var image;
    var customFont5;
    var customFont3;
    var customFont4;
    var customFont5255S;
    var customFont3255S;
    var customFont4255S;
    var BreakTime1;
    var WorkTime = true;
    var Time2 = false;
    var vibedata;
    var deviceSettings = System.getDeviceSettings();
    var partNumber = deviceSettings.partNumber;
    var Pause = false;
    var Settings = false;
    var HRS = "12 Hour";
    var ChangeSetting = 1;
    var PomodoroCount = 0;
    var LastDate;
    

    function initialize() {
        View.initialize();
        _sigma = true;
        changeState = false;
    }

    function onLayout(dc as Dc) as Void {  
        setLayout(Rez.Layouts.MainLayout(dc));
        customFont5 = WatchUi.loadResource(Rez.Fonts.customFont5); 
        customFont3 = WatchUi.loadResource(Rez.Fonts.customFont3); 
        customFont4 = WatchUi.loadResource(Rez.Fonts.customFont4); 
        customFont5255S = WatchUi.loadResource(Rez.Fonts.customFont5255S); 
        customFont3255S = WatchUi.loadResource(Rez.Fonts.customFont3255S); 
        customFont4255S = WatchUi.loadResource(Rez.Fonts.customFont4255S); 
        _Title = findDrawableById("title");
        _Timer = findDrawableById("timer");
        _CurrentTime = findDrawableById("current_time");
        image = findDrawableById("pomodoro1_icon");
        _Title.setText("Pomodoro Timer");
        if (partNumber.equals("006-B3993-00") || partNumber.equals("006-B3991-00")) {
            if (customFont5 != null) {
                _Title.setFont(customFont5255S);
                _Timer.setFont(customFont3255S);
                _CurrentTime.setFont(customFont4255S);
                image.setBitmap(Rez.Drawables.fr255s_icon);
                image.setLocation(0, 0);
            } else {
                System.println("❌ Failed to load custom font!");
            }
        } else {
            if (customFont5 != null) {
                _Title.setFont(customFont5);
                _Timer.setFont(customFont3);
                _CurrentTime.setFont(customFont4);
            } else {
                System.println("❌ Failed to load custom font!");
            }
        }
        PomodoroCount = Storage.getValue("pomodoroCount");
        if (PomodoroCount == null) {
            PomodoroCount = 0;
        }
        Storage.setValue("pomodoroCount", PomodoroCount);
        LastDate = Storage.getValue("lastDate");
        if (LastDate == null) {
            LastDate = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT)[:day];
        }
        Storage.setValue("lastDate", LastDate);

    }

    function checkDateReset() {
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT)[:day];

        if (LastDate == null) {
            LastDate = today;
        } else if (LastDate != today) {
            PomodoroCount = 0;
            LastDate = today;
        }

    }


    function onShow() as Void {
        ChangeState();

        // ✅ Only start if not already started
        if (m_Timer == null) {
            delayedStart();
        }

        setTimerValue(workDuration);
        WatchUi.requestUpdate();

        // ✅ Resume countdown timer if needed
        if (_inProgress && Pause && _timers == null) {
            _timers = new Timer.Timer();
            _timers.start(method(:countDownTick), 1000, true);
        }
    }

    function onHide() {
        if (_inProgress && !Pause) {
            Pause = true;
            _Title.setText("Paused");
        }
    }
    function delayedStart() as Void {
        CurrentTime();
        updateTimer();
    }

    function updateTimer() as Void {
        if (m_Timer != null) {
            m_Timer.stop();
            m_Timer = null; // ✅ Prevent memory leak
        }

        m_Timer = new Timer.Timer();
        m_Timer.start(method(:Update), 1000, true);
    }


    function SigmaTimer() as Void {
        _currentDuration = workDuration;
        _timers = new Timer.Timer();
        _timers.start(method(:countDownTick), 1000, true);
        countDownTick();
    }

    function ResetTimer() as Void {
        stopTimer();

        if (m_Timer != null) {
            m_Timer.stop();
            m_Timer = null;
        }

        _skipTimer = false;
        _sigma = true;
        WorkTime = true;
        Pause = false;
        _inProgress = false;

        ChangeState(); // ✅ Make sure durations match current toggle state
        _currentDuration = workDuration;

        _Title.setText("Pomodoro Timer");
        setTimerValue(_currentDuration);
        updateTimer(); // optional
    }



    function stopTimer() as Void {
        if (_timers != null) {
            _timers.stop();
            _timers = null;
        }
        _inProgress = false;
    }


    function Update() as Void {
        CurrentTime();
        ChangeState();
    }

    function min(a, b) {
        return a < b ? a : b;
    }

    function max(a, b) {
        return a > b ? a : b;
    }
    

    function ChangeState() as Void {
        if (changeState == true) {
            workDuration = 50 * 60;
            breakDuration = 10 * 60;
        } else if (changeState == false) {
            workDuration = 25 * 60;
            breakDuration = 5 * 60;
        }
        
    }

    function countDownTick() as Void {
        if (Pause) {
            _Title.setText("Paused");
            return;
        }
        if (Attention has :vibrate) {
            vibedata =
            [
                new Attention.VibeProfile(100, 1000), // On for two seconds
                new Attention.VibeProfile(0, 500),  // Off for two seconds
            ];
        }

        if (_currentDuration <= 0) {
            _skipTimer = true;
            Attention.vibrate(vibedata);
            if (_currentDuration <= 0) {
                _skipTimer = true;
                Attention.vibrate(vibedata);
                
                checkDateReset(); // make sure this runs regularly

                if (!WorkTime) {
                    PomodoroCount += 1;
                    Storage.setValue("pomodoroCount", PomodoroCount);
                     Storage.setValue("lastDate", LastDate);
                    WatchUi.requestUpdate();
                }
            }
            

        }

        if (_skipTimer == true) {
            _sigma = !_sigma;  // Toggle state
            WorkTime = _sigma; // Ensure WorkTime follows _sigma

            if (WorkTime) {
                _currentDuration = workDuration;
                _Title.setText("Time to work!");
            } else {
                _currentDuration = breakDuration;
                _Title.setText("Break Time!");
            }

            _skipTimer = false; // Reset after switching states
        }

        
        setTimerValue(_currentDuration);
        if (Pause == false) {
            _currentDuration--;
        }
        
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
        if (HRS.equals("12 Hour")) {
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
            }     
        } else {
            if (_CurrentTime != null) {
                var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
                var hour = info[:hour];
                var minute = info[:min];
                var minuteStr = (minute < 10) ? "0" + minute.toString() : minute.toString();
                var timeStr = hour.toString() + ":" + minuteStr;
                _CurrentTime.setText(timeStr);
                WatchUi.requestUpdate();
            }     
        }
        
        
    }

    function StopTimers() as Void {
        if (m_Timer != null) {
            m_Timer.stop();
        } 
        if (_timers != null) {
             _timers.stop();
        }
    }
    function showSettingsMenu() {

        if (Settings) {
            Settings = false;
        } else {
            Settings = true;
            ResetTimer();
        }
        WatchUi.pushView(new WatchUi.Menu(), new PomodoroTimerMenuInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
    var _settingsInitialized = false;
    var _lastDrawnHRS = null;
    var _lastPomodoroCount = null;
    var _lastChangeSetting = -1;

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, width, height);
        var centerX = width / 2;
        var centerY = height / 2;
        
        if (Settings) {
            
            if (!_settingsInitialized) {
                ResetTimer();
                _settingsInitialized = true;
            }

            // Clear the background
            

            // Draw title
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, centerY - (width / 3).toNumber(), customFont4, "Settings", Graphics.TEXT_JUSTIFY_CENTER);

            // Draw Format setting
            dc.setColor(ChangeSetting == 1 ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, centerY - (width / 10).toNumber(), customFont5255S, "Format: " + HRS, Graphics.TEXT_JUSTIFY_CENTER);

            // Draw Pomodoro count
            dc.setColor(ChangeSetting == 2 ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, centerY + (width / 15).toNumber(), customFont5255S, "Total Pomodoros: " + PomodoroCount, Graphics.TEXT_JUSTIFY_CENTER);

            // Draw Exit option
            dc.setColor(ChangeSetting == 3 ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(centerX, centerY + (width / 4).toNumber(), customFont5255S, "Exit App", Graphics.TEXT_JUSTIFY_CENTER);

            // Cache current state
            _lastDrawnHRS = HRS;
            _lastPomodoroCount = PomodoroCount;
            _lastChangeSetting = ChangeSetting;

        } else {
            _settingsInitialized = false;
            View.onUpdate(dc);

            if (_currentDuration == null) {
                return;
            } 

            var radius = min(centerX, centerY) - 10;
            var totalDuration = WorkTime ? workDuration : breakDuration;
            if (totalDuration <= 0) {
                 return;

            }
            if (!_inProgress && !Pause) {
                dc.clear();
            } else {
                var elapsed = totalDuration - _currentDuration;
                var progressPercent = max(0.0, min(elapsed.toFloat() / totalDuration.toFloat(), 1.0));
                var progressAngle = progressPercent * 360.0;

                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
                try {
                    dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, progressAngle + 90);
                    dc.drawArc(centerX, centerY, radius - 1, Graphics.ARC_CLOCKWISE, 90, progressAngle + 90);
                    if (!(partNumber.equals("006-B3993-00") || partNumber.equals("006-B3991-00"))) {
                        dc.drawArc(centerX, centerY, radius - 2, Graphics.ARC_CLOCKWISE, 90, progressAngle + 90);
                    }
                } catch(e) {
                    System.println("🚨 drawArc failed: " + e.toString());
                }
            }
        }
    }


}
