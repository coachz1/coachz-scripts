--[[
 * ReaScript Name: Create Stealth Sends
 * Description: A script for REAPER ReaScript.
 * Instructions: Run script to Create Stealth Sends
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
Run script to Create Stealth Sends
Select track(s) to create stealth sends on and run script action.  
Script will prompt for channels to send on and then create the sends.
--]]


-- clear console
reaper.ShowConsoleMsg("")

-- create simpler console messager
function Msg(param)
	reaper.ShowConsoleMsg(param.."\n")
end

debugParent = false -- disable detail messages
debugChild  = false	-- disable main messages
--debugParent = true -- disable detail messages
--debugChild  = true	-- disable main messages

-- prompt for channels to create sends on
retval, chans = reaper.GetUserInputs( "Sends Destination Channels ", 1, "Ex: For 1/2 enter 0102", "")
chanL = string.sub(chans, 1, 2)
chanR = string.sub(chans, 3, 4)
--if debugParent then Msg("chanL: " .. chanL .. "  chanR: " .. chanR)  end

-- chanL = 11  -- hard code for testing
-- chanR = 12
channels = tostring(chanL) .. "/" .. tostring(chanR)
numAudioChannels = 64
--if debugParent then Msg("Destination Channels: " .. channels)  end


-- get first selected track and name
tr = reaper.GetSelectedTrack( 0, 0 )
retval, trackName = reaper.GetTrackName( tr, "" )
if debugParent then Msg("ENTERING Get Sel Tracks and Parents - Code Block .........") end
if debugParent then Msg("--------------------------------------------------")  end
if debugParent then Msg("First Selected Track Name: " .. trackName .. "\n") end

-- test for first parent and then count number of parent tracks
tr = reaper.GetParentTrack( tr )  
	--retval, curTrackName = reaper.GetTrackName( tr, "" )     if debug then
	--Msg("what Parent Tracks: " .. curTrackName) end

-- count number of parents above selected track
numParents = 0
while( tr )
do
	numParents = numParents + 1

	if(tr)
	then
		retval, curTrackName = reaper.GetTrackName( tr, "" )
		if debugParent then Msg("Parent Tracks: " .. curTrackName) end	
		topParentTrack = tr
	end

	tr = reaper.GetParentTrack( tr )  -- tr is next parent track
end

if debugParent then Msg("\nNumber of Parent Tracks: " .. numParents) end
rev, topParentTrackName = reaper.GetTrackName( topParentTrack, "" )
if debugParent then Msg("Top Parent Track: " .. topParentTrackName) end




-- ------------------------------------------------------------
-- send top level parent to fx track with channels that match
-- ------------------------------------------------------------
trkCount = reaper.CountTracks( 0 )  -- count of tracks
if debugParent then Msg("\n\nENTERING Top Parent - Code Block.........") end
if debugParent then Msg("--------------------------------------------------")  end
if debugParent then Msg("Total # of Tracks " .. trkCount) end

-- loop over tracks to get names and test for matching of desired channels
for k=0, trkCount-1 do
	tr = reaper.GetTrack( 0, k )
	retval, trName = reaper.GetTrackName( tr, "" )
	if debugParent then Msg("Track Name at index: " .. k .. " (track ".. k+1 ..") ".. trName) end

	-- check if track matches desired channels then add send from top parent to it
	if string.match(trName, channels) then  -- ex: if 22/23 is in the track name
		if debugParent then Msg("FX Track Name: " .. trName .. " is a match for " .. channels) end

		-- get list of tracks by id
		matchTr =  reaper.GetTrack( 0, k )
		retval, matchTrName = reaper.GetTrackName( matchTr, "" )
		if debugParent then Msg("Matched FX Track: " .. matchTrName) end

		-- find top parent track of the currently selected track(s)
		selectedTr = reaper.GetSelectedTrack( 0, 0 )
		for i = 1, numParents, 1 do
			selectedTr = reaper.GetParentTrack( selectedTr )  
			retval, parentTrackName = reaper.GetTrackName( selectedTr, "" )
		end
		if debugParent then Msg("\nTop Parent Track: [" .. parentTrackName .. "]") end


		-- count number of sends on current parent
		numParentSends = reaper.GetTrackNumSends( selectedTr, 0 )
		if debugParent then Msg("\n".. numParentSends .. " Send(s) Currently on Track: [" .. parentTrackName .. "]") end


		-- loop sends for this top parent to check if desired audio channels already exist
		-- if there are no sends on the parent this loop does not run
		sendChansExist = false
		for j = 0, numParentSends-1 do
	   		send = reaper.GetTrackSendInfo_Value( selectedTr, 0, j, "I_SRCCHAN"  )
	   		-- if send = 0 then 1/2,  19 then 20/21
	   		curSendChans = (math.floor(send+.5) + 1) .. "/" .. (math.floor(send+.5) + 2)

	   		if debugParent then Msg("Send is on raw I_SRCCHAN value: " .. send .. "-->" .. curSendChans) end

	   		if channels == curSendChans then
	   			sendChansExist = true
	   			if debugParent then Msg("--" ..tostring(sendChansExist) .. " Channel exists: " .. channels .. " on send index " .. j) end
	   		end
	   	end


	   	-- if no send channel exist for desired channels, then create it
	  	if(not sendChansExist) then
	  		if debugParent then Msg("Send on top parent for desired channels does not exist") end
			
			--create send from top level parent to fx channel that matches desired channels.
		  	retval, destTrackName = reaper.GetTrackName( matchTr, "" )
			if debugParent then Msg("\nNew Send is being add from: [" .. parentTrackName .. "] to [" .. destTrackName .. "]" .. " on Channels " .. channels) end

			-- set track channels
			reaper.SetMediaTrackInfo_Value(topParentTrack, "I_NCHAN", numAudioChannels);
			if debugParent then Msg("numAudioChannels: " .. numAudioChannels) end

			newSendIdx = reaper.CreateTrackSend( selectedTr, matchTr )
			if debugParent then Msg("newSendIdx: " .. newSendIdx) end

			-- return the number of the last send added. starts with 1
			lastSend = reaper.GetTrackNumSends( selectedTr , 0 )
			if debugParent then Msg(" lastSend: " .. lastSend) end

			-- set send output audio channels ex: 33/34
			if debugParent then Msg(" chanL: " .. chanL .. "\n") end

			-- set send output audio channels ex: 33/34
			reaper.BR_GetSetTrackSendInfo( selectedTr, 0, newSendIdx, "I_SRCCHAN", 1, chanL-1)
			reaper.BR_GetSetTrackSendInfo( selectedTr, 0, newSendIdx, "I_DSTCHAN", 1, 0)
		end




		-- ------------------------------------------------------------
		-- add sends from currently selected tracks to immediate parent
		-- ------------------------------------------------------------
		if debugChild then Msg("\nENTERING Add sends from selected tracks to immediate parent - code block")  end
		if debugChild then Msg("--------------------------------------------------")  end
		-- get count of selected tracks 
	    ct = reaper.CountSelectedTracks( 0 )

	    -- loop over selected tracks and add sends to parent
	    for i = 0, ct-1 do
     
	      -- get each selected track
	      selectedTr = reaper.GetSelectedTrack( 0, i )
	      parentTr = reaper.GetParentTrack( selectedTr )
	       
	      -- get track names as you iterate over each selected track
	      retval, selectedTrackName = reaper.GetTrackName( selectedTr, "" )
	      if debugChild then Msg("Track Name: " .. selectedTrackName) end

	      retval, pTrName = reaper.GetTrackName( parentTr, "" )
	      if debugChild then Msg("ParentTrack Name: " .. pTrName) end
	         
	        -- count number of sends on current parent
			numSends = reaper.GetTrackNumSends( selectedTr, 0 )
			if debugChild then Msg(numSends .. " Send(s) Currently on Track: [" .. pTrName .. "]") end

			sendChansExist = false
			for j = 0, numSends-1 do
		   		send = reaper.GetTrackSendInfo_Value( selectedTr, 0, j, "I_DSTCHAN"  )
		   		-- if send = 0 then 1/2,  19 then 20/21
		   		curSendChans = (math.floor(send+.5) + 1) .. "/" .. (math.floor(send+.5) + 2)
		   		if debugChild then Msg("Send is on raw I_DSTCHAN value: " .. send .. "-->" .. curSendChans) end

		   		if channels == curSendChans then
		   			sendChansExist = true
		   			if debugChild then Msg("--" .. tostring(sendChansExist) .. " Channel exists: " .. channels .. " on send index " .. j) end
		   		end
		   	end


		  	if(not sendChansExist) then
				--create send from top level parent to fx channel that matches desired channels.
			  	retval, parentTrackName = reaper.GetTrackName( parentTr, "" )
				if debugChild then Msg("\nNew Send is being added from: [" .. selectedTrackName .. "] to [" .. pTrName .. "]" .. " on channels " .. channels) end

				-- set track channels
				reaper.SetMediaTrackInfo_Value( selectedTr, "I_NCHAN", numAudioChannels )
			
				-- create send
				reaper.CreateTrackSend( selectedTr, parentTr )
				reaper.SetMediaTrackInfo_Value(parentTr, "I_NCHAN", numAudioChannels);  -- increase channels to allow send to display 

				-- return the number of the last send added. starts with 1
				lastSend = reaper.GetTrackNumSends( selectedTr , 0 )
				if debugChild then Msg(" lastSend: " .. lastSend) end

				-- set send output audio channels ex: 33/34
				if debugChild then Msg(" chanL: " .. chanL .. "\n") end
				
				--reaper.BR_GetSetTrackSendInfo( selectedTr, 0, lastSend-1, "I_SRCCHAN", 1, chanL-1)
				--reaper.SetMediaTrackInfo_Value(selectedTr, "I_NCHAN", 6);
				--reaper.SetMediaTrackInfo_Value(selectedTr, "I_NCHAN", numAudioChannels);
				--reaper.BR_GetSetTrackSendInfo( selectedTr, 0, lastSend-1, "I_DSTCHAN", 1, chanL-1)
				--reaper.BR_GetSetTrackSendInfo( selectedTr, 0, 0, "I_DSTCHAN", 1, 21)
				
				-- set destination channels
				reaper.SetTrackSendInfo_Value( selectedTr, 0, lastSend - 1, "I_DSTCHAN", chanL-1 )

				-- set volume of send
				reaper.BR_GetSetTrackSendInfo( selectedTr, 0, lastSend - 1, "D_VOL", 1, 0)

			end
	   end

		

	end
end


