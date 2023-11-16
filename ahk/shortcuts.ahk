; Reference
; https://www.autohotkey.com/docs/v2/Hotkeys.htm

; TODO(agarun): https://gist.github.com/hubisan/5981dcf2a8560df9b434dd3b7d8e357b AHK Open Chrome with Profile
^!`:: Run "C:\Program Files\Google\Chrome\Application\chrome.exe" --profile-directory="Profile 1"

!n::
    If WinExist("Untitled - Notepad") { ; Quick notes
        WinActivate
    } else {
        Run, "notepad"
    }
    return

^!Esc::
    If WinExist("Apex Legends") { ; Prevent alt-tabing in games
        Return
    } else {
        WinClose
    }
    return

; I use Microsoft PowerToys Keyboard Manager to natively remap shortcuts
; like Win + 0-9 into hotkeys like alt + 1, alt + q, etc.
; See .skhdrc for those.
; For everything else I can use AHK.

!3::
    If WinExist("ahk_exe olk.exe") { ; Outlook
        WinActivate
    } else {
        Run, "olk"
    }
    return

!4::
    If WinExist("ahk_exe TablePlus.exe") { ; DB
        WinActivate
    } else {
        Run, "C:\Program Files\TablePlus\TablePlus.exe"
    }
    return

; Replicate macos behavior to cycle through windows (cmd + `)
; https://superuser.com/questions/1604626/easy-way-to-switch-between-two-windows-of-the-same-app-in-windows-10
^`::
    ; The 'else' is not as good as MacOS' behavior because it closes all other windows
    ; when cycling. However Windows does have proper cycling for shortcutted programs
    ; (win + 0-9). So we can take advantage of that for Chrome and Code, and the rest
    ; use our custom cycling code.
    WinGet, ActiveProcessName, ProcessName, A
    if (ActiveProcessName = "chrome.exe") {
        ; Remap the hotkey to Ctrl + Win + 1 for Chrome
        Send, ^#1 ; Alt + ` is Chrome, but it's in position 1
        Return
    }
    else if (ActiveProcessName = "Code.exe") {
        ; Remap the hotkey to Ctrl + Win + 3 for Chrome
        Send, ^#3 ; Alt + 2 is Code, but it's in position 3
        Return
    }
    else {
        IF GetKeyState("LAlt")
            Return
        WinGetClass, OldClass, A
        WinGet, ActiveProcessName, ProcessName, A
        WinGet, WinClassCount, Count, ahk_exe %ActiveProcessName%
        IF WinClassCount = 1
            Return
        loop, 2 {
            WinSet, Bottom,, A
            WinActivate, ahk_exe %ActiveProcessName%
            WinGetClass, NewClass, A
            if (OldClass <> "CabinetWClass" or NewClass = "CabinetWClass")
                break
        }
    }
return