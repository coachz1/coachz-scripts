--[[
 * ReaScript Name: UnMute Master Track
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
 * Notification:  written by the awesome EDGEMEAL !!!!!
--]]
--[[ ----- INSTRUCTIONS ====>

Run script to UnMute Master Track

--]]


local track = reaper.GetMasterTrack(0)
if track then
  local env_count = reaper.CountTrackEnvelopes(track) 
  for j = 0, env_count-1 do
    local env = reaper.GetTrackEnvelope(track, j)
    local br_env = reaper.BR_EnvAlloc(env, false)
    local active, visible, armed, inLane, laneHeight, defaultShape, _, _, _, env_type, faderScaling = reaper.BR_EnvGetProperties(br_env) 
    if (env_type == 0) then -- 0->Volume, 1->Volume (Pre-FX), 2->Pan, 3->Pan (Pre-FX), etc..
      if not active then
        reaper.BR_EnvSetProperties(br_env, true, visible, false, inLane, laneHeight, defaultShape, faderScaling)
        reaper.BR_EnvFree(br_env, true) 
      end
      reaper.BR_EnvFree(br_env, false)
      break
    else
      reaper.BR_EnvFree(br_env, false)
    end  
  end
end