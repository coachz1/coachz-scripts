--[[
 * ReaScript Name: Count tracks needing to Freeze
 * Description: A script for REAPER ReaScript.
 * Instructions: Run script to display a count of tracks that can be frozen
 * Screenshot: 
 * Author: coachz
 * Repository: GitHub > coachz1 > coachz-scripts
 * Repository URI: https://raw.githubusercontent.com/coachz1/coachz-scripts/main/index.xml
 * File URI: 
 * License: MIT
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 7.x
 * Extensions: None
 * Version: 1.0
 * Notification:  I have used code from many sources to make my scripts.  If any of my code is from your code, let me know so I can give due credit !!
--]]
 
--[[
 * Changelog:
 * v1.0 (2024-01-14)
	+ Initial Release
--]]

--[[ ----- INSTRUCTIONS ====>

Run script to display a count of tracks that can be frozen

--]]

-- clear console
reaper.ShowConsoleMsg("")

-- create simpler console messager
function Msg(param) reaper.ShowConsoleMsg(param.."\n") end

debug  = false    -- disable main messages
--if debug then Msg("Test") end
--/////////////////////////////////////////////////////////////////////


-- Check for tracks to freeze
numToFreeze = 0

	-- loop over all tracks
	cntTracks = reaper.CountTracks( proj )
	--if debug then Msg("Num Tracks: " .. cntTracks) end

-- loop over each track to select tracks with fx and unmuted media
    for i = 0, cntTracks - 1 do
		
		-- get current track
	 	local curTrack = reaper.GetTrack( 0, i )
		
		-- get track name
	    retval, trackName = reaper.GetTrackName( curTrack, "" )
		if debug then Msg("\n Track Name: " .. i+1 .. " is " .. trackName) end

		hasFX = false
		hasMedia = false
		unMutedMedia = 0
		
		-- get track fx
		local ok, trackFX = reaper.TrackFX_GetFXName(curTrack, 0)
		
		-- check if track has fx, set hasFX true or false
		if string.len (trackFX) > 0 then
			if debug then Msg("\t FX " .. trackFX .. " exists on this track") end	
			hasFX = true
		else
			if debug then Msg("\t FX does not exist on this track") end	
			hasFX = false
		end
		
		
		-- check if track has unmuted media on it
		numMediaItems = reaper.CountTrackMediaItems(curTrack)
		if debug then Msg("\t Num Media Items " .. numMediaItems) end
		
		-- loop over MEDIA ITEMS
		unMutedMedia = 0
		if numMediaItems > 0 then 
			if debug then Msg("\t Num Media Items > 0 --> " .. numMediaItems) end
			
			for j=0, numMediaItems - 1 do
				mediaItem = reaper.GetTrackMediaItem(curTrack, j)
				muteState = reaper.GetMediaItemInfo_Value(mediaItem, "B_MUTE")
				
				if muteState == 0 then 
					unMutedMedia = unMutedMedia + 1
				end
			
				if debug then Msg("\t muteState " .. j .. " --> " .. muteState) end	
				unMutedMedia = unMutedMedia + muteState
			end		
		end  -- end loop over MEDIA ITEMS
		if debug then Msg("\t unMutedMedia count is " .. unMutedMedia) end	
		
		
		if hasFX == true and unMutedMedia > 0 then
			-- count track
			numToFreeze = numToFreeze + 1		
			if debug then Msg( "------------->Freeze track: " .. i+1) end
		end
	--  end check each track for fx and media items	

  
    end  -- end loop over each track to find tracks with fx and unmuted media
	


local msg_title = ""

if numToFreeze > 1 then
	msg_str = numToFreeze-1 .. " tracks to freeze"
	--if debug2 then Msg( numToFreeze-1 .. " tracks to freeze") end
else
	msg_str = "Nothing to Freeze"
	-- if debug2 then Msg( "Nothing to Freeze !!!" ) end
end


local timer = .2 -- Time in seconds
local wnd_w, wnd_h = 175, 75

-- Get the screen size
local __, __, scr_w, scr_h = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, 1)

-- Reference time to check against
local time = os.time()

-- Window background
gfx.clear = reaper.ColorToNative(255,255,255)

-- Open the window
--          Name    w       h   dock    x                   y
gfx.init(msg_title, wnd_w, wnd_h, 0, (scr_w - wnd_w) / 2, (scr_h - wnd_h) / 2)

gfx.setfont(1, "Arial", 18)

-- Black
gfx.set(0, 0, 0, 1)

-- Center the text
local str_w, str_h = gfx.measurestr(msg_str)
local txt_x, txt_y = (gfx.w - str_w) / 2, (gfx.h - str_h) / 2

local function Main()
    
    -- Get the keyboard/window state
    local char = gfx.getchar()
    
    -- Reasons to end the script:
    --  Esc           Window closed         Timer is up
    if char == 27 or char == -1 or (os.time() - time) > timer then return end
    
    -- Center the text
    gfx.x, gfx.y = txt_x, txt_y
    gfx.drawstr(msg_str)
    
    -- Maintain the window and keep the script running
    gfx.update()
    reaper.defer(Main)
    
end

Main()

-- wait
--[[local function Msg(str)
   reaper.ShowConsoleMsg(tostring(str) .. "\n")
end--]]

time_start = reaper.time_precise()
--Msg("Starting a timer for 1 second...")

local function Main2()

    local elapsed = reaper.time_precise() - time_start

    if elapsed >= 0.5 then
        --Msg("1 seconds have elapsed! Ending the loop.")
        -- focus midi editor
        reaper.SN_FocusMIDIEditor()
        return
    else
        reaper.defer(Main2)
    end
    
end

Main2()
