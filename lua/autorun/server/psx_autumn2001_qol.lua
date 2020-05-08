--[[
	psx_autumn2001 QoL map patcher
	Script by D4 the (Choco) Fox
	Original map by Cool, all rights reserved.
]]--

-- Prevent this script from running when it isn't psx_autumn2001
if ( game.GetMap() != "psx_autumn2001" ) then return; end


-- Table to store entities we should remove
local FORCE_REMOVAL_ENTITY_TABLE = {
	[ "-1080 -776 -56" ] = { [ "classname" ] = "lua_run" },
	[ "-1080 -760 -56" ] = { [ "classname" ] = "lua_run" },
	[ "-1096 -760 -56" ] = { [ "classname" ] = "lua_run" },
	[ "-1128 -760 -56" ] = { [ "classname" ] = "lua_run" },
	[ "-1144 -760 -56" ] = { [ "classname" ] = "lua_run" },
	[ "-1032 -760 -56" ] = { [ "classname" ] = "lua_run" },
	[ "backroomsletter*" ] = { [ "mponly" ] = true }
}

-- Table to store entities we should patch
local PATCH_ENTITY_TABLE = {
	[ "game_text" ] = { [ "mponly" ] = true, [ "addoutput" ] = { [ "spawnflags" ] = "1" } },
	[ "-1024 -1024 160" ] = { [ "classname" ] = "lua_run", [ "addoutput" ] = { [ "Code" ] = "timer.Simple( 0.01, function() game.CleanUpMap() end )" } }
}

-- Perform map sanitization
local function SanitizeMap()

	--[[
		Remove all entities in the above FORCE_REMOVAL_ENTITY_TABLE automatically
		This uses an origin value with a classname to determine if it is a valid entity to delete
	]]--
	for k, v in pairs( FORCE_REMOVAL_ENTITY_TABLE ) do
	
		if ( ( game.SinglePlayer() && !v.mponly ) || !game.SinglePlayer() ) then
		
			-- If this doesn't exist we assume the key on the first loop is a targetname (and applies to everything under that targetname)
			if ( v.classname ) then
			
				local vectorizedOrigin = Vector( k )
				for k2, v2 in ipairs( ents.FindInSphere( vectorizedOrigin, 1 ) ) do
				
					if ( v2:GetClass() == v.classname ) then
					
						v2:Remove()
						break
					
					end
				
				end
			
			else
			
				for k2, v2 in ipairs( ents.FindByName( k ) ) do
				
					v2:Remove()
				
				end
			
			end
		
		end
	
	end

	--[[
		Patch all entities in the above PATCH_ENTITY_TABLE automatically
		This uses an origin value with a classname to determine if it is a valid entity to modify
	]]--
	for k, v in pairs( PATCH_ENTITY_TABLE ) do
	
		if ( ( game.SinglePlayer() && !v.mponly ) || !game.SinglePlayer() ) then
		
			-- If this doesn't exist we assume the key on the first loop is a classname (and applies to everything under that classname)
			if ( v.classname ) then
			
				local vectorizedOrigin = Vector( k )
				for k2, v2 in ipairs( ents.FindInSphere( vectorizedOrigin, 1 ) ) do
				
					if ( v2:GetClass() == v.classname ) then
					
						for k3, v3 in pairs( v.addoutput ) do
						
							v2:Fire( "addoutput", k3 .. " " .. v3 )
						
						end
						break
					
					end
				
				end
			
			else
			
				for k2, v2 in ipairs( ents.FindByClass( k ) ) do
				
					for k3, v3 in pairs( v.addoutput ) do
					
						v2:Fire( "addoutput", k3 .. " " .. v3 )
					
					end
				
				end
			
			end
		
		end
	
	end

end


-- Call a respawn on player(s)
local function RespawnPlayers( ply, fadeIn )

	if ( IsValid( ply ) && ply:IsPlayer() ) then
	
		if ( fadeIn ) then ply:ScreenFade( SCREENFADE.IN, color_black, 0.125, 0.125 ); end
		ply:Spawn()
	
	else
	
		-- Targets all players
		for i, ply in ipairs( player.GetAll() ) do
		
			if ( IsValid( ply ) ) then
			
				if ( fadeIn ) then ply:ScreenFade( SCREENFADE.IN, color_black, 0.125, 0.125 ); end
				ply:Spawn()
			
			end
		
		end
	
	end

end


-- Teleports all players to this player
local function TeleportPlayersToPlayer( ply )

	if ( !IsValid( ply ) || !ply:IsPlayer() ) then return; end

	for i, ply2 in ipairs( player.GetAll() ) do
	
		if ( IsValid( ply ) && IsValid( ply2 ) && ( ply2 != ply ) && ply:Alive() && ply2:Alive() ) then
		
			ply2:ScreenFade( SCREENFADE.IN, color_black, 0.125, 0.125 )
			ply2:SetPos( ply:GetPos() )
			ply2:SetEyeAngles( ply:EyeAngles() )
		
		end
	
	end

end


-- Picks a random player that is alive, needing an argument containing a player to ensure it does not choose that player
local function GetRandomPlayer( ply )

	if ( !IsValid( ply ) || !ply:IsPlayer() ) then return; end

	local players = {}
	for i, ply2 in ipairs( player.GetAll() ) do
	
		if ( IsValid( ply ) && IsValid( ply2 ) && ( ply2 != ply ) && ply2:Alive() ) then
		
			table.insert( players, ply2 )
		
		end
	
	end

	return table.Random( players )

end


-- Called after all entities have been initialized
local function psxInitPostEntity()

	-- Sanitize the map
	SanitizeMap()

end
hook.Add( "InitPostEntity", "psxInitPostEntity", psxInitPostEntity )


-- Table to hook onto certain entity inputs and run a function
local ENTITY_INPUT_HOOK_TABLE = {
	[ "apartmentdoor" ] = { [ "mponly" ] = true, [ "entinput" ] = "lock", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "shopblockbrush" ] = { [ "mponly" ] = true, [ "entinput" ] = "enable", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "garageluke" ] = { [ "mponly" ] = true, [ "entinput" ] = "enable", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "tunneldoor1" ] = { [ "mponly" ] = true, [ "entinput" ] = "close", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "tunneldoor2" ] = { [ "mponly" ] = true, [ "entinput" ] = "lock", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "padikdoorclosed" ] = { [ "mponly" ] = true, [ "entinput" ] = "enable", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "roomtrigger2" ] = { [ "mponly" ] = true, [ "entinput" ] = "enable", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "backroomsholeblock1" ] = { [ "mponly" ] = true, [ "entinput" ] = "enable", [ "activatorclass" ] = "player", [ "execute" ] = function( ply ) TeleportPlayersToPlayer( ply ); end },
	[ "backroomsendblock" ] = { [ "mponly" ] = true, [ "entinput" ] = "disable", [ "activatorclass" ] = "player", [ "execute" ] = function() ents.FindByName( "deathrestart" )[ 1 ]:Fire( "RunCode" ); end },
	[ "deathplayerfreeze" ] = { [ "mponly" ] = true, [ "entinput" ] = "activate", [ "execute" ] = function() for i, ply in ipairs( player.GetAll() ) do ply:Freeze( true ); end end },
	[ "endgamefreeze" ] = { [ "mponly" ] = true, [ "entinput" ] = "activate", [ "execute" ] = function() for i, ply in ipairs( player.GetAll() ) do ply:Freeze( true ); end end }
}

-- Function to catch ALL entity inputs/outputs
local function psxAcceptInput( ent, input, activator, caller, value )

	-- Use ENTITY_INPUT_HOOK_TABLE to hook some functions to certain entity I/O
	if ( ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ] && ( ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].entinput == string.lower( input ) ) && ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].execute ) then
	
		if ( IsValid( activator ) && ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].activatorclass && ( ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].activatorclass == activator:GetClass() ) ) then
		
			ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].execute( activator )
		
		else
		
			ENTITY_INPUT_HOOK_TABLE[ ent:GetName() ].execute()
		
		end
	
	end

end
hook.Add( "AcceptInput", "psxAcceptInput", psxAcceptInput )


-- Called before we clean up the map
local function psxPreCleanupMap()

	-- Silently kill all players
	for i, ply in ipairs( player.GetAll() ) do
	
		if ( IsValid( ply ) && ply:Alive() ) then
		
			ply:KillSilent()
		
		end
	
	end

	-- Respawns all players
	RespawnPlayers()

end
hook.Add( "PreCleanupMap", "psxPreCleanupMap", psxPreCleanupMap )


-- Called after we clean up the map
local function psxPostCleanupMap()

	-- Sanitize the map
	SanitizeMap()

end
hook.Add( "PostCleanupMap", "psxPostCleanupMap", psxPostCleanupMap )


-- Called on player spawn, here we do a few silly things to make our experience better
local function psxPlayerSpawn( ply )

	-- Change the collision group for multiplayer
	if ( !game.SinglePlayer() ) then
	
		ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		ply:CollisionRulesChanged()
	
	end

	-- Set player speed and jump power
	local function DelayedSpawnApply()
	
		if ( IsValid( ply ) ) then
		
			ply:RemoveSuit()
			ply:SetRunSpeed( 150 )
			ply:SetWalkSpeed( 100 )
			ply:SetJumpPower( 180 )
			ply:SetAvoidPlayers( false )
		
		end
	
	end
	timer.Simple( 0.1, DelayedSpawnApply )

end
hook.Add( "PlayerSpawn", "psxPlayerSpawn", psxPlayerSpawn )


-- Used by the game to select a spawnpoint for the player
local function psxPlayerSelectSpawn( ply )

	-- Spawn the player on a random player if we can
	if ( !game.SinglePlayer() ) then
	
		local randomPlayer = GetRandomPlayer( ply )
		if ( IsValid( randomPlayer ) ) then
		
			return randomPlayer
		
		end
	
	end

end
hook.Add( "PlayerSelectSpawn", "psxPlayerSelectSpawn", psxPlayerSelectSpawn )


-- This determines if a spawnpoint is suitable but we'll just force it to return true here
local function psxIsSpawnpointSuitable()

	return true

end
hook.Add( "IsSpawnpointSuitable", "psxIsSpawnpointSuitable", psxIsSpawnpointSuitable )
