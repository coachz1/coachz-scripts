--[[
 * ReaScript Name: Mute Master Track
 * Description: A script for REAPER ReaScript.
 * Instructions: Run script to display a count of tracks that can be frozen
 * Screenshot: 
 * Author: coachz
 * Repository: GitHub > coachz1 > coachz-scripts
 * Repository URI: https://github.com/coachz1/coachz-scripts/raw/main/index.xml
 * File URI: 
 * License: MIT
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 7.x
 * Extensions: None
 * Version: 1.0
 * Notification:  I have used code from many sources to make my scripts.  If any of my code is from your code, let me know so I can give due credit !!
--]]
--[[ ----- INSTRUCTIONS ====>

Run script to Mute Master Track

--]]

-- clear console
reaper.ShowConsoleMsg("")

-- create simpler console messager
function Msg(param) reaper.ShowConsoleMsg(param.."\n") end

function bool2string(b) return b and "true" or "false" end 

debug  = false    -- disable main messages
--debug  = true   -- enable main messages
--if debug then Msg("Test") end
--/////////////////////////////////////////////////////////////////////


local ID = '_S&M_CYCLACTION_11' --< Command ID for your custom script
local butn_state = reaper.GetToggleCommandStateEx(0, reaper.NamedCommandLookup(ID))
if debug then Msg("butn_state: " .. butn_state) end
-- Returns: 0=off, 1=on, -1=NA


if(butn_state == 1) then
	
	-- Custom: Cycle Toggle Master Volume Automation
	commandID = reaper.NamedCommandLookup("_S&M_CYCLACTION_11")
	reaper.Main_OnCommand(commandID, 0)

end



