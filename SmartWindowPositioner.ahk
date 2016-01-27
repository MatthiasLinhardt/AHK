#SingleInstance Force
#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%

ProcessWindowsKeyPlusDirection(pressedDirection)
{	
	GetMonitorInfoForActiveWindow(x, y, w, h, isPivot)
	
	;if monitor is in pivot mode, overwrite original snapping with vertical snapping:
	if(isPivot)
	{	
		;snapping is calculated for lower two thirds, right side to upper third:
		h /= 3			
		if (pressedDirection = 1)
		{
			y += h
			h *= 2
		}
		
		;if user wants to get from pivot screen to regular screen, send Shift-Win-Key.
		;if user keeps pressing towards outwards boundary of pivot screen, switch vertical positions.
		WinGetPos, winX, winY, winW, winH, A
		
		if (x > 0)
		{
			if (pressedDirection = 0)
			{				
				SendShiftWindowsPlusDirectionInput(pressedDirection)	
				Return
			}
			else if(winX = x AND winY = y AND winH = h AND winW = w)
			{
				h /= 2
				y -= h
			}			
		}
		else
		{
			if (pressedDirection = 1)
			{
				SendShiftWindowsPlusDirectionInput(pressedDirection)				
				Return
			}
			else if(winX = x AND winY = y AND winH = h AND winW = w)
			{
				y += h
				h *= 2
			}			
		}
		
		;actually perform vertical snapping of window:
		WinMove,A,,%x%,%y%,%w%,%h%
	}
	else
	{	
		;forward key input for snapping via operating system:		
		SendRegularWindowsPlusDirectionInput(pressedDirection)
		
		GetMonitorInfoForActiveWindow(x, y, w, h, isPivot)
		
		if (isPivot)
		{
			ProcessWindowsKeyPlusDirection(pressedDirection)
		}
	}
}

GetMonitorInfoForActiveWindow(byref x, byref y, byref w, byref h, byref isPivot)
{
	;Check on which monitor the current window is:
	WinGet activeWin, ID, A
	activeMon := GetMonitorIndexFromWindow(activeWin)
	
	;Get screen space of monitor:
	SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%	
	x := MonitorWorkAreaLeft
	y := MonitorWorkAreaTop
	w := MonitorWorkAreaRight - MonitorWorkAreaLeft
	h := MonitorWorkAreaBottom - MonitorWorkAreaTop
	
	;Check if monitor is in landscape or portrait/pivot mode:
	isPivot := false	
	IfGreater,h,%w%
	{
		isPivot := true
	}		
}

SendRegularWindowsPlusDirectionInput(direction)
{
	;suspend is necessary for not getting our hotkeys re-triggered by our own key activation.
	Suspend	
	if (direction = 0)
	{
		Send,#{Left}
	}
	else
	{
		Send,#{Right}
	}	
	Suspend
}

SendShiftWindowsPlusDirectionInput(direction)
{
	;Moving onto the main screen ends on wrong snapping side, thus componsate.
	;Windows key is held down for allowing further snapping commands without pressing the key again.
	Suspend	
	if (direction = 0)
	{
		Send,+#{Left}#{Right}#{Right}{LWin down}
	}
	else
	{
		Send,+#{Right}#{Left}#{Left}{LWin down}
	}	
	Suspend
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

#Left::ProcessWindowsKeyPlusDirection(0)
#Right::ProcessWindowsKeyPlusDirection(1)