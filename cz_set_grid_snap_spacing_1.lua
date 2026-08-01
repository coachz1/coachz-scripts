-- set Grid Snap Spacing to 1
retval = reaper.SNM_SetDoubleConfigVar( "projgriddivsnap", 4)

-- focus midi editor
hwnd = reaper.MIDIEditor_GetActive()

-- send command to midi editor
reaper.MIDIEditor_OnCommand(hwnd, "40204")