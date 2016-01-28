#SingleInstance Force
#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

;mode: N > 0  => Close windows on screen N, 
;      N = 0  => Close windows on same screen as current window
;      N = -1 => Close windows on same screen as mouse
mode := -1

ProcessWindowsD()
{	
	global mode
	
	if(mode > 0)
	{
		activeMon := mode
	}
	else if(mode < 0)
	{
		MouseGetPos, mousePosX, mousePosY, idOfWindowUnderMouse
		WinGetTitle,thisTitle, ahk_id %idOfWindowUnderMouse%
		if(thisTitle <> "Program Manager" AND thisTitle <> "Start" AND thisTitle <> "Plugfree NETWORK" AND thisTitle <> "")
		{
			activeMon := GetMonitorIndexFromWindow(idOfWindowUnderMouse)
		}
		else
		{
			Return
		}
	}
	else
	{
		;Check on which monitor the current window is:
		WinGet activeWin, ID, A
		activeMon := GetMonitorIndexFromWindow(activeWin)
	}
			
	;Get all windows and minimize them if they are on the same monitor as the active window:
	WinGet,listOfIDs,list,,,Program Manager,
	Loop, %listOfIDs%
	{
		thisId := listOfIDs%A_Index%
		WinGetTitle,thisTitle, ahk_id %thisId%
		if(thisTitle <> "Program Manager" AND thisTitle <> "Start" AND thisTitle <> "Plugfree NETWORK" AND thisTitle <> "")
		{
			thisMon := GetMonitorIndexFromWindow(thisId)
			if(thisMon = activeMon)
			{
				WinMinimize, ahk_id %thisId%
			}
		}
	}
}

GetMonitorIndexFromWindow(windowHandle)
{    
    monitorIndex := 1 ;Starts with 1, not 0!

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2)) 
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) 
    {
        monitorLeft   := NumGet(monitorInfo,  4, "Int")
        monitorTop    := NumGet(monitorInfo,  8, "Int")
        monitorRight  := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")
        workLeft      := NumGet(monitorInfo, 20, "Int")
        workTop       := NumGet(monitorInfo, 24, "Int")
        workRight     := NumGet(monitorInfo, 28, "Int")
        workBottom    := NumGet(monitorInfo, 32, "Int")
        isPrimary     := NumGet(monitorInfo, 36, "Int") & 1

        SysGet, monitorCount, MonitorCount

        Loop, %monitorCount%
        {
            SysGet, tempMon, Monitor, %A_Index%

            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom))
            {
                monitorIndex := A_Index
                break
            }
        }
    }

    return monitorIndex
}

#D::ProcessWindowsD()