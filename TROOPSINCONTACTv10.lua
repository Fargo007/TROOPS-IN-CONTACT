--TROOPS IN CONTACT! BY [BSD] FARGO http://www.blacksharkden.com
--Released for public use with attribution please.
--user-configurable options in the script at this time are described below.
--See mission briefing for instructions on changes.
--Now get out there and support those guys on the ground!

-- Version: 9

-----------------------------------------------------------------------------------
--Configuration:

-- Menu Options:  showTICmenu allows the menu to be disabled (if a mission designer wishes to control aspects of the script directly. unquoted true/false.
-- default: showTICmenu = true
showTICmenu = true

-- TICMessageShowTime: unquoted number of seconds to maintain the initial contact messages on the screen. Default is 120. You can clear them by placing a map mark.
-- Using a zero will disable the contact text messages entirely.
TICMessageShowTime = 120 --120

-- UseTICSounds: unquoted true/false value to indicate that the initial message sounds should, or should not be played. Default is true.
-- You must have the 20 sound files loaded into the mission. See the example trigger that does this.
UseTICSounds = true

-- TIC Grid Areas (quoted string three required)
-- These are the larger rectangular or round zones that define a TIC patrol area in which TIC episodes can occur.
-- Defaults are "TIC-grid-1" -2, and -3. No need to change these but if you wish to use a different name, you may.
TICArea1 = "TIC-grid-1"
TICArea2 = "TIC-grid-2"
TICArea3 = "TIC-grid-3"

-- TIC episode Zones: The names (quoted string) of the zones inside the TIC-grid-1 and TIC-grid-2 areas. Defaults are "grid1" and "grid2"
-- Any, and all zones containing this string will be consumed into TIC as a possible TIC area. Don't use this string in unrelated zones.
-- These need to be inside their corresponding TIC-Grid-areas.
-- Defaults:
-- grid1zoneprefix = "grid1"
-- grid2zoneprefix = "grid2"
-- grid3zoneprefix = "grid3"
grid1zoneprefix = "grid1"
grid2zoneprefix = "grid2"
grid3zoneprefix = "grid3"

-- onstation_time: The unquoted number of seconds (interval) on which a check is made to see if there is an active helicopter or plane in a TIC grid.
-- think of this as the maximum time you would fly around and wait to be called after either heavy or light are activated.
onstation_time = 30 --120

-- flanking_percentage: Unquoted number representing the percentage that a main element will separate from their support elements
-- and attempt to flank the friendlies by 90 degrees. A 0 here means never. A 100 means always. Disabled if retreat_percentage > 0.
-- default: flanking_percentage = 50
flanking_percentage = 0 --50

-- retreat_percentage: Unquoted number representing the percentage that a HEAVY OR LIGHT main element will separate from their support elements
-- and retreat away from the engagement area.
retreat_percentage = 1000 --100

-- retreat_formation: How the retreat of the main element will be conducted. "On Road" or "Off Road" are recommended for starters but any valid MOOSE 
-- formation definition can be used. "On Road" and a retreat_distance of 4000-10000 seems to show a really nice effect.
-- this is entirely dependent on AI behavior so don't have an expectation that anything you put here will work like it seems it should.
-- retreat_formation = "On Road"
retreat_formation = "Off Road"

-- retreat_distance: Unquoted number (meters) that a retreating element will move. 4000 is recommended.
retreat_distance = 5000 --4000

-- friendly_return_fire: Unquoted value, true/false. If true, friendlies will return fire for target marking purposes for the amount of time
-- indicated in friendly_fire_time, then they will cease fire, and a message "YOU ARE CLEARED HOT" will show on screen.
-- If used, the intent is for you to listen to the radio messages, observe their fire for correlation, and prepare to engage. Default == true.
friendly_return_fire = true

-- friendly_fire_time: The number of seconds the friendlies should return fire for marking purposes. The enemy are set immortal for this period
-- of time, so the friendlies don't obliterate them before you arrive, spoiling the scenario. Wait for "CLEARED HOT" to send ordnance.
friendly_fire_time = 50

-- bugout_delay: Unquoted number of seconds post-spawn at which a main element's flank/retreat movement will begin if called for.
-- default: bugout_delay = 120
bugout_delay = 120 --120

-- bugout_announce: Unquoted value, true/false. If true, and a flank or retreat occurs, the event and direction will be announced via text msgs.
bugout_announce = true

-- x,z offset distances from friendlies of enemy contacts when they spawn. 300-400 or so are recommended but you can tune this to suit. Unquoted numbers.
--default offsetX = 300
--default offsetZ = 400
offsetX = 400
offsetZ = 400

-- Flags reserved for script use:
-- 4050 (sets either light (1), or heavy (2). Not configurable.

-- Group Naming Conventions and roles:
-- Groups & Statics do not have to be referenced by name. Instead, a naming convention is used.
-- Name the groups and statics you wish to include in the script according to this convention:

-- Statics: (these are cannon fodder) FRIENDLYSTATIC-1,FRIENDLYSTATIC-2 .. etc.
-- Friendlies: (the groups that need your help) FRIENDLIES-1, FRIENDLIES-2, .. etc.
-- Heavy: (when a heavy TIC engagement is selected) HEAVY-1, HEAVY-2, .. etc.
-- Light: (when a light TIC engagement is selected) LIGHT-1, LIGHT-2 .. etc.

-- YOU MUST HAVE MINIMUM 1 CORRECTLY NAMED UNIT IN EACH CATEGORY, and the first one must be -1 !!! (e.g. LIGHT-1, HEAVY-1, etc).
-- Any errors, the first step is to check the dcs.log in Saved Games\Logs\dcs.log

-- hit_check_interval: Unquoted number of seconds at which a recurring check is made to see if the enemy has been hit or sufficiently killed.
-- highly recommended you leave this at 60. Too short will cause a race condition of overlapping voice messages.
hit_check_interval = 60 --60

-- Laser codes to use, if a target lase is possible (must have LoS with the first unit of the group). Unquoted numbers in a lua table. 
-- If you want only one, limit this table to a single entry ,e.g.
-- lasercode = { 1772 }

lasercode = { 1688, 1776, 1113, 1772 }

-- time in seconds to lase. Unquoted number
lasertime = 180
-- There's no support for changing anything below this line. Caveat emptor. ;-)
-----------------------------------------------------------------------------------

env.info("TROOPS IN CONTACT v10 BY [BSD] FARGO START...")

last_value_4050 = 0

-- Build object sets by name
--Statics:
CannonFodderTable = {}
staticSet = SET_STATIC:New():FilterPrefixes("FRIENDLYSTATIC"):FilterOnce()
staticCount = 0
staticSet:ForEachStatic(function (grp)
  staticCount = staticCount + 1
  namestring = "CannonFodder" .. staticCount
  namestring = SPAWNSTATIC:NewFromStatic( grp:GetName(), country.id.CJTF_BLUE )
  table.insert(CannonFodderTable,namestring)
end )

--Light:
lightTable = {}
lightSet = SET_GROUP:New():FilterCategoryGround():FilterCoalitions("red"):FilterPrefixes("LIGHT"):FilterOnce()
lightSet:ForEachGroup(function (grp)
  table.insert(lightTable, grp:GetName())
end )
TICbaddieLight = SPAWN:NewWithAlias("LIGHT-1","convoy-TICbaddieLight"):InitRandomizeTemplate(lightTable):InitHeading(1,359)

--Heavy:
heavyTable = {}
heavySet = SET_GROUP:New():FilterCategoryGround():FilterCoalitions("red"):FilterPrefixes("HEAVY"):FilterOnce()
heavySet:ForEachGroup(function (grp)
  table.insert(heavyTable, grp:GetName())
end )
TICbaddieHeavy = SPAWN:NewWithAlias("HEAVY-1","convoyTICbaddieHeavy"):InitRandomizeTemplate(heavyTable):InitHeading(1,359)


--SUPPORT:
supportTable = {}
supportSet = SET_GROUP:New():FilterCategoryGround():FilterCoalitions("red"):FilterPrefixes("SUPPORT"):FilterOnce()
supportSet:ForEachGroup(function (grp)
  table.insert(supportTable, grp:GetName())
end )

--Error checking
local count_statics = staticSet:Count()
if count_statics == 0 then 
  MESSAGE:New("TROOPS IN CONTACT ERROR! - THERE ARE NO CORRECTLY NAMED STATIC OBJECTS IN THE MISSION!\nCHECK YOUR STATIC OBJECTS AND MAKE SURE NAME AND UNIT NAME MATCH." ,625,""):ToAll()
end
local count_light = lightSet:Count()
if count_light == 0 then 
  MESSAGE:New("TROOPS IN CONTACT ERROR! - THERE ARE NO CORRECTLY NAMED LIGHT GROUPS IN THE MISSION!\nCHECK YOUR LIGHT OBJECTS NAMES." ,625,""):ToAll()
end
local count_heavy = heavySet:Count()
if count_heavy == 0 then 
  MESSAGE:New("TROOPS IN CONTACT ERROR! - THERE ARE NO CORRECTLY NAMED HEAVY GROUPS IN THE MISSION!\nCHECK YOUR HEAVY OBJECTS NAMES." ,625,""):ToAll()
end
local count_support = supportSet:Count()
if count_support == 0 then 
  MESSAGE:New("TROOPS IN CONTACT ERROR! - THERE ARE NO CORRECTLY NAMED SUPPORT GROUPS IN THE MISSION!\nCHECK YOUR SUPPORT OBJECTS NAMES." ,625,""):ToAll()
end


TICbaddieSupport = SPAWN:NewWithAlias("SUPPORT-1","convoy-TICbaddieSupport"):InitRandomizeTemplate(supportTable):OnSpawnGroup(
function (supportgrp) 
      local immcmd = {id = 'SetImmortal',params = {value = true}}
      supportgrp:_GetController():setCommand(immcmd)
      local mortalTask = supportgrp:TaskFunction("SGroupMortalAgain")
      function SGroupMortalAgain(s_mortals)
        local immcmd = {id = 'SetImmortal',params = {value = false}}
        s_mortals:_GetController():setCommand(immcmd)
        --env.info("TICDEBUG: support group is mortal again!")
      end
      supportgrp:SetTask(mortalTask,friendly_fire_time)
end)

--FRIENDLIES:
friendliesTable = {}
friendliesSet = SET_GROUP:New():FilterCategoryGround():FilterCoalitions("blue"):FilterPrefixes("FRIENDLIES"):FilterOnce()
friendliesSet:ForEachGroup(function (grp)
  table.insert(friendliesTable, grp:GetName())
end )
Friendly = SPAWN:NewWithAlias("FRIENDLIES-1","convoy-TICFriendlies"):InitHeading(0,1):InitRandomizeTemplate(friendliesTable)

--For tracerfire marking by friendlies
TRACERMARK = SPAWN:NewWithAlias("TRACERMARK","convoy-TRACERMARK"):InitHeading(0,1)

tracermark_groupname = "none"
FirePointVec2 = "none"

-- Enemy Behavior conflict - Flanking OR Retreat. Retreat wins.

if flanking_percentage > 0 and retreat_percentage > 0 then
  flanking_percentage = 0
end

Retreat_Direction = "none"
Flanking_Direction = "none"

function GoldTIC(_args,TICGridZone)
  --env.info("TICDEBUG: GoldTIC() start...")
  Direction = "none"

  TICzones = _args
  TICZoneObject = TICGridZone
  _G[TICZoneObject] = TICZoneObject 
  TICgroupset = SET_GROUP:New():FilterCategoryAirplane():FilterCoalitions("blue"):FilterCategoryHelicopter():FilterStart()
  

  flag4050 = USERFLAG:New(4050)
  flag4050value = flag4050:Get()
  --env.info("DEBUG 4050: " .. flag4050value)
  if flag4050value == 1 then
    env.info("DEBUG: GoldTIC flag 1, LIGHT...")
    TICBaddie = TICbaddieLight
  elseif flag4050value == 2 then
    env.info("DEBUG: GoldTIC flag 2, HEAVY...")
    TICBaddie = TICbaddieHeavy
  elseif flag4050value == 0 then
    env.info("DEBUG: 4050 TIC IS OFF")
    return
  end

  routedGroupName = nil

  TICBaddie:OnSpawnGroup(
    function( sgrp )
    
      local immcmd = {id = 'SetImmortal',params = {value = true}}
      sgrp:_GetController():setCommand(immcmd)
      local mortalTask = sgrp:TaskFunction("GroupMortalAgain")
      function GroupMortalAgain(mortals)
        local immcmd = {id = 'SetImmortal',params = {value = false}}
        mortals:_GetController():setCommand(immcmd)
        --env.info("TICDEBUG: group is mortal again!")
      end
      sgrp:SetTask(mortalTask,friendly_fire_time)
      
      CharlieMike = false
      samesameIniGroup = nil
      TICBaddieUnit1 = sgrp:GetUnit(1)
      _G[TICBaddieUnit1] = TICBaddieUnit1  
      TICBaddieGroupName = sgrp:GetName()
      TICBaddieUnit1Heading = sgrp:GetUnit(1):GetHeading()
      retreat_number = math.random(1,100)
      env.info("TICDEBUG: retreat_number: " .. retreat_number)
      TICBaddieZone = ZONE_GROUP:New(sgrp:GetName(),sgrp,250)
      sgrp:HandleEvent( EVENTS.Hit  )
      function sgrp:OnEventHit( EventData )
        shooterCoalition = EventData.IniCoalition

        if shooterCoalition == 2 then

          local DeadScheduler = SCHEDULER:New( nil, function()
              env.info("TICDEBUG: hit_check_scheduler fires")

              TICBaddieZone:Scan({Object.Category.UNIT},{Unit.Category.GROUND_UNIT})
              if TICBaddieZone:CheckScannedCoalition(coalition.side.RED) == true then
                --MESSAGE:New("DEBUG 145 - Enemies still there!" ,15,""):ToAll()
                --env.info("TICDEBUG: red still in zone")
                -- GOOD EFFECTS ON TARGET!
                --retreat
                if (retreat_number < retreat_percentage) then
                  local TICBaddiePointVec2 = sgrp:GetPointVec2()
                  local X = TICBaddiePointVec2:GetLat()
                  local Y = TICBaddiePointVec2:GetLon() 
                  local GTFO_coord = POINT_VEC2:New( X + retreat_offset1,Y + retreat_offset2 ):GetCoordinate()

                  --GTFO_coord = TICBaddiePointVec2:GetCoordinate()
                  --GTFO_coord = sgrp:GetUnit(1):GetOffsetCoordinate(retreat_offset1,0,retreat_offset2)
                  
                  if routedGroupName ~= TICBaddieGroupName then
                    sgrp:OptionAlarmStateGreen()
                    sgrp:RouteGroundTo(GTFO_coord,math.random(25,55), retreat_formation,0)
                    routedGroupName = TICBaddieGroupName
                    --GTFO_coord:MarkToAll("route")
                    GTFO_vec2 = GTFO_coord:GetVec2()
                    --MESSAGE:New("TICDEBUG 284 - routing!: " ,125,""):ToAll()
                    if bugout_announce == true then
                      TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)                                               
                       MESSAGE:New("... From SANDMAN-2-6: Squirters on the move to the " .. Retreat_Direction .. "!" ,TICMessageShowTime,""):ToGroup(grp)
                      end )
                    end  
                  end

                end

                if EventData.IniGroup == samesameIniGroup then
                  return
                else
                  if UseTICSounds == true then
                    hitsound = USERSOUND:New("goodeffectontarget2.ogg"):ToGroup(EventData.IniGroup,13)                    
                  end
                  TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)                           
                                                   
                  MESSAGE:New("... From SANDMAN-2-6: good effect on target!" ,TICMessageShowTime,""):ToGroup(grp) end)      
                  
                  samesameIniGroup = EventData.IniGroup
                  --env.info("TICDEBUG: good effect sound played")
                  return
                end
              else
                --env.info("TICDEBUG: red NOT in zone, weareCM2 coming :60")
                if CharlieMike == false then
                  if UseTICSounds == true then
                  TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)                           
                    local deadsound = USERSOUND:New("weareCM2.ogg"):ToGroup(grp) end)
                  end
                  TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)                            
                    MESSAGE:New("have secondaries in the target area. All enemies appear to be down. Thanks for the support, we are CM!" ,15,""):ToGroup(grp)
                  end)
                  CharlieMike = true
                end
              end
          end, {}, hit_check_interval) 

        end
      end

      -- env.info("DEBUG: last_value? : " .. last_value_4050)

        env.info("TICDEBUG: Spawning support!!!")

        ticbaddieheavyVec2 = flanking_coord:GetVec2()
        ticbaddiessupportcoord = sgrp:GetUnit(1):GetOffsetCoordinate(-15,0,-15)
        local flanking_number = math.random(1,101)
        env.info("TICDEBUG: flankingnum: " .. flanking_number)
        env.info("TICDEBUG: flankingpct: " .. flanking_percentage)

        if flanking_number < flanking_percentage then
          local FLANKING = SCHEDULER:New( nil,
            function()
              sgrp:TaskRouteToVec2(ticbaddieheavyVec2,10, FORMATION.EchelonL)
              env.info("TICDEBUG: flanking! ")
              if bugout_announce == true then             
                TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)                                               
                  MESSAGE:New("... From SANDMAN-2-6: enemy is attempting to flank from the " .. Flanking_Direction .. "!" ,TICMessageShowTime,""):ToGroup(grp)
                end )
              end 

            end, {}, bugout_delay )

        end

        TICbaddieSupport:SpawnFromCoordinate(ticbaddiessupportcoord)

    end)

  Friendly:InitRandomizeZones(TICzones)
  Friendly:OnSpawnGroup(function (spawngroup)
  unit1 = spawngroup:GetUnit(1)
  
-- TRACERMARK
   Tracermark_coord = unit1:GetOffsetCoordinate(-25,0,-25)
   TRACERMARK:OnSpawnGroup(function (tmarker) 
    _G[tracermark_groupname] = tmarker:GetName()
    env.info("TICDEBUG: _G[tracermark_groupname]: " .. _G[tracermark_groupname])
    tmarker:OptionAlarmStateGreen()
      local immcmd = {id = 'SetImmortal',params = {value = true}}
      tmarker:_GetController():setCommand(immcmd)
        local fireStop = tmarker:TaskFunction("TmarkerHoldFire")
        function TmarkerHoldFire(tmarker) 
          tmarker:OptionROEHoldFire()            
        end     
     end)
   TRACERMARK:SpawnFromCoordinate(Tracermark_coord)
   


      --spawngroup:OptionROEHoldFire()
      local immcmd = {id = 'SetImmortal',params = {value = true}}
      spawngroup:_GetController():setCommand(immcmd)
      
      --orig Direction_num = math.random(1,8)
      Direction_num = math.random(1,8)
      offset1 = math.random(offsetX,offsetZ)
      offset2 = math.random(offsetX,offsetZ)

      if Direction_num == 1 then
        Direction = "NORTH"
        offset1 = math.random(offsetX,offsetZ)
        offset2 = 0
        direction_sound = "north.ogg"
        flanking_offset1 = 0
        flanking_offset2 = math.random(offsetX,offsetZ)
        retreat_offset1 = retreat_distance
        retreat_offset2 = 0
        Flanking_Direction = "East"
      end
      if Direction_num == 2 then
        Direction = "NORTHEAST"
        offset1 = math.random(offsetX,offsetZ)
        offset2 = math.random(offsetX,offsetZ)
        direction_sound = "northeast.ogg"
        flanking_offset1 = math.random(-offsetX,-offsetZ)
        flanking_offset2 = math.random(offsetX,offsetZ)
        retreat_offset1 = retreat_distance
        retreat_offset2 = retreat_distance
        Flanking_Direction = "Southeast"
      end
      if Direction_num == 3 then
        Direction = "EAST"
        offset1 = 0
        offset2 = math.random(offsetX,offsetZ)
        direction_sound = "east.ogg"
        flanking_offset1 = math.random(-offsetX,-offsetZ)
        flanking_offset2 = 0
        retreat_offset1 = 0
        retreat_offset2 = retreat_distance
        Flanking_Direction = "South"
      end
      if Direction_num == 4 then
        Direction = "SOUTHEAST"
        offset1 = math.random(-offsetX,-offsetZ)
        offset2 = math.random(offsetX,offsetZ)
        direction_sound = "southeast.ogg"
        flanking_offset1 = math.random(-offsetX,-offsetZ)
        flanking_offset2 = math.random(-offsetX,-offsetZ)
        retreat_offset1 = -retreat_distance
        retreat_offset2 = retreat_distance
        Flanking_Direction = "Southwest"
      end
      if Direction_num == 5 then
        Direction = "SOUTH"
        offset1 = math.random(-offsetX,-offsetZ)
        offset2 = 0
        direction_sound = "south.ogg"
        flanking_offset1 = 0
        flanking_offset2 = math.random(-offsetX,-offsetZ)
        retreat_offset1 = -retreat_distance
        retreat_offset2 = 0
        Flanking_Direction = "West"
        

      end
      if Direction_num == 6 then
        Direction = "SOUTHWEST"
        offset1 = math.random(-offsetX,-offsetZ)
        offset2 = math.random(-offsetX,-offsetZ)
        direction_sound = "southwest.ogg"
        flanking_offset1 = math.random(offsetX,offsetZ)
        flanking_offset2 = math.random(-offsetX,-offsetZ)
        retreat_offset1 = -retreat_distance
        retreat_offset2 = -retreat_distance
        Flanking_Direction = "Northwest"
        
      end
      if Direction_num == 7 then
        Direction = "WEST"
        offset1 = 0
        offset2 = math.random(-offsetX,-offsetZ)
        direction_sound = "west.ogg"
        flanking_offset1 = math.random(offsetX,offsetZ)
        flanking_offset2 = 0
        retreat_offset1 = 0
        retreat_offset2 = -retreat_distance
        Flanking_Direction = "North"
        
      end
      if Direction_num == 8 then
        Direction = "NORTHWEST"
        offset1 = math.random(offsetX,offsetZ)
        offset2 = math.random(-offsetX,-offsetZ)
        direction_sound = "northwest.ogg"
        flanking_offset1 = math.random(offsetX,offsetZ)
        flanking_offset2 = math.random(offsetX,offsetZ)
        retreat_offset1 = retreat_distance
        retreat_offset2 = -retreat_distance
        Flanking_Direction = "Northeast"
        
      end
      Retreat_Direction = Direction
      --Flanking_Direction = Direction
 
      shouldernum = math.random(1,2)
      if shouldernum == 1 then
        shoulderDir = "LEFT"
        shoulderSound = "leftshoulder.ogg"
      else
        shoulderDir = "RIGHT"
        shoulderSound = "rightshoulder.ogg"
      end

      smokecolornum = math.random(1,5)
      if smokecolornum == 1 then smokecolor = "GREEN"
        spawngroup:Smoke(SMOKECOLOR.Green,55,1) smoke_sound = "greensmoke.ogg" end
      if smokecolornum == 2 then smokecolor = "RED"
        spawngroup:Smoke(SMOKECOLOR.Red,55,1) smoke_sound = "redsmoke.ogg" end
      if smokecolornum == 3 then smokecolor = "WHITE"
        spawngroup:Smoke(SMOKECOLOR.White,55,1) smoke_sound = "whitesmoke.ogg" end
      if smokecolornum == 4 then smokecolor = "ORANGE"
        spawngroup:Smoke(SMOKECOLOR.Orange,55,1) smoke_sound = "orangesmoke.ogg" end
      if smokecolornum == 5 then smokecolor = "BLUE"
        spawngroup:Smoke(SMOKECOLOR.Blue,55,1) smoke_sound = "bluesmoke.ogg" end

      TICcoord = unit1:GetOffsetCoordinate(offset1,0,offset2)
      flanking_coord = unit1:GetOffsetCoordinate(flanking_offset1,0,flanking_offset2)
      cannonfoddercoord1 = unit1:GetOffsetCoordinate(30,0,30)
      cannonfoddercoord2 = unit1:GetOffsetCoordinate(-30,0,-30)
      cannonfoddercoord3 = unit1:GetOffsetCoordinate(-30,0,30)

      local CannonFodder = CannonFodderTable[math.random(#CannonFodderTable)]

      CannonFodder:SpawnFromCoordinate(cannonfoddercoord1, math.random(1,359), "convoy-FRIENDLYSTATIC1")
      CannonFodder:SpawnFromCoordinate(cannonfoddercoord2, math.random(1,359), "convoy-FRIENDLYSTATIC2")
      CannonFodder:SpawnFromCoordinate(cannonfoddercoord3, math.random(1,359), "convoy-FRIENDLYSTATIC3")


      TICBaddie:SpawnFromCoordinate(TICcoord)
      _SETTINGS:SetMGRS_Accuracy(2)

        --Friendly fire at enemy, while they are immortal for friendly_fire_time      
      if friendly_return_fire == true then
        spawngroup:OptionAlarmStateGreen()
        FirePointCoord = unit1:GetOffsetCoordinate(offset1 ,0,offset2)
        FirePointVec2 = FirePointCoord:GetVec2()
        _G[FirePointVec2] = FirePointCoord:GetVec2()
        _G[FirePointCoord] = FirePointCoord
        local fireTask = spawngroup:TaskFireAtPoint(FirePointVec2,1,nil,3221225470,8)
        local fireStop = spawngroup:TaskFunction("GroupHoldFire")
        function GroupHoldFire(grp) 
          grp:OptionROEHoldFire() 
          TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)          
            MESSAGE:New(".... YOU ARE CLEARED HOT!", TICMessageShowTime - friendly_fire_time, ""):ToGroup(grp)
            if UseTICSounds == true then
              soundplayCH = USERSOUND:New("clearedhot.ogg"):ToGroup(grp)
            end
          end)                
        end
        spawngroup:SetTask(fireTask,1)
        spawngroup:SetTask(fireStop,friendly_fire_time)
        spawngroup:OptionAlarmStateGreen()
        spawngroup:OptionROT(ENUMS.ROT.NoReaction)           
        --FirePointCoord:MarkToAll("firepoint")
        distance_markedby_sound = "markedbymytracerfire.ogg"
        distance_marking_text = "TARGET MARKED BY MY TRACER FIRE.."               
      else
        distance_markedby_sound = "distance.ogg"
        distance_marking_text = "NO MARK ON TARGET AT THIS TIME"        
      end
      
      friendlycoorstring = cannonfoddercoord1:ToStringMGRS(Settings)
      TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)

        MESSAGE:New("ATTACK ELEMENT, SANDMAN 26... STAND BY FOR FIVE LINE... ", TICMessageShowTime, ""):ToGroup(grp)
        MESSAGE:New("1. TYPE 2 CONTROL, BOMB ON TARGET. MISSILES FOLLOWED BY ROCKETS & GUNS. \n2. MY POSITION " .. friendlycoorstring .. " MARKED BY " .. smokecolor .. " SMOKE!", TICMessageShowTime, ""):ToGroup(grp)
        MESSAGE:New("3. TARGET LOCATION: " .. Direction .. " 300 to 500 METERS!", TICMessageShowTime, ""):ToGroup(grp)
        MESSAGE:New("4. ENEMY TROOPS AND VEHICLES IN THE OPEN, " .. distance_marking_text, TICMessageShowTime, ""):ToGroup(grp)
        MESSAGE:New("5. " .. shoulderDir .. " SHOULDER. PULL YOUR DISCRETION. DANGER CLOSE, FOXTROT WHISKEY!", TICMessageShowTime, ""):ToGroup(grp)
        MESSAGE:New("..reactivate TIC when ready again..", 15, ""):ToAll()

      end) --foreachgroupcompletely
 
      if UseTICSounds == true then
        
        TICgroupset:ForEachGroupCompletelyInZone(TICZoneObject,function (grp)
          soundplay1 = USERSOUND:New("5line.ogg"):ToGroup(grp,1)
          soundplay2 = USERSOUND:New("controlmarkedby.ogg"):ToGroup(grp,9)
          soundplay3 = USERSOUND:New(smoke_sound):ToGroup(grp,19)
          soundplay4 = USERSOUND:New(direction_sound):ToGroup(grp,22)
          soundplay5 = USERSOUND:New(distance_markedby_sound):ToGroup(grp,26)
          soundplay6 = USERSOUND:New(shoulderSound):ToGroup(grp,33)

        end)
      end
  end)
  Friendly:Spawn()
end --function

--Grid 1
function GoldTICGrid1 ()
  local Grid1Zones = { }
  local Grid1ZoneSet = SET_ZONE:New():FilterPrefixes(grid1zoneprefix):FilterOnce()
  Grid1ZoneSet:ForEachZone(function (z)
    table.insert(Grid1Zones, z)
  end)
  TicZone = ZONE:New(TICArea1)  
  GoldTIC(Grid1Zones,TicZone)
end
--Grid 2
function GoldTICGrid2 ()
  local Grid2Zones = { }
  local Grid2ZoneSet = SET_ZONE:New():FilterPrefixes(grid2zoneprefix):FilterOnce()
  Grid2ZoneSet:ForEachZone(function (z)
    table.insert(Grid2Zones, z)
  end)
  TicZone = ZONE:New(TICArea2)  
  GoldTIC(Grid2Zones,TicZone)
end
--Grid 3
function GoldTICGrid3 ()
  local Grid3Zones = { }
  local Grid3ZoneSet = SET_ZONE:New():FilterPrefixes(grid3zoneprefix):FilterOnce()
  Grid3ZoneSet:ForEachZone(function (z)
    table.insert(Grid3Zones, z)
  end)
  TicZone = ZONE:New(TICArea3)    
  GoldTIC(Grid3Zones,TicZone)
end

function TICsetflag (arg)

  flag4050 = USERFLAG:New('4050')

  if arg == "light" then
    flag4050:Set(1)
    last_value_4050 = 1
    MESSAGE:New("YOU ARE SET TO RESPOND TO LIGHT CALLS FOR FIRE\n FROM TROOPS IN CONTACT.", 15, ""):ToAll()
  elseif arg == "heavy" then
    flag4050:Set(2)
    last_value_4050 = 2

    MESSAGE:New("YOU ARE SET TO RESPOND TO HEAVY CALLS FOR FIRE\n FROM TROOPS IN CONTACT.", 15, ""):ToAll()

  elseif arg == "off" then
    flag4050:Set(0)
    last_value_4050 = 0

    MESSAGE:New("YOU WILL NOT RECEIVE CALLS FOR FIRE\n FROM TROOPS IN CONTACT.", 15, ""):ToAll()

  end
  --env.info("TICDEBUG 4050: " .. flag4050:Get() )
end --function

function TICCleanup()

  local  blueunits = SET_GROUP:New():FilterActive():FilterPrefixes("convoy-TICFriendlies"):FilterOnce()
  local bluestatics = SET_STATIC:New():FilterPrefixes({"convoy-FRIENDLYSTATIC1"},{"convoy-FRIENDLYSTATIC2"},{"convoy-FRIENDLYSTATIC3"}):FilterOnce()

  blueunits:ForEachGroupAlive( function (grp)
    grp:Destroy()
  end)

  bluestatics:ForEachStatic( function (sta)
    sta:Destroy()
  end)

end

function TICSounds(_arg)
  if _arg == "true" then
    env.info("DEBUG: INSIDE TICSounds, arg: true" )      
    MESSAGE:New("TIC engagements will play sound.", 15, ""):ToAll()
    UseTICSounds = true
  elseif _arg == "false" then
    env.info("DEBUG: INSIDE TICSounds, arg: false" )  
    MESSAGE:New("TIC announcement sounds are off.", 15, ""):ToAll()
    UseTICSounds = false

  end

end


function NewSmoke()
  smokecolornum = math.random(1,5)
  if smokecolornum == 1 then smokecolor = "GREEN"
    cannonfoddercoord3:Smoke(SMOKECOLOR.Green,55,1) smoke_sound = "greensmoke.ogg" end
  if smokecolornum == 2 then smokecolor = "RED"
    cannonfoddercoord2:Smoke(SMOKECOLOR.Red,65,1) smoke_sound = "redsmoke.ogg" end
  if smokecolornum == 3 then smokecolor = "WHITE"
    cannonfoddercoord1:Smoke(SMOKECOLOR.White,75,1) smoke_sound = "whitesmoke.ogg" end
  if smokecolornum == 4 then smokecolor = "ORANGE"
    cannonfoddercoord3:Smoke(SMOKECOLOR.Orange,35,1) smoke_sound = "orangesmoke.ogg" end
  if smokecolornum == 5 then smokecolor = "BLUE"
    cannonfoddercoord2:Smoke(SMOKECOLOR.Blue,45,1) smoke_sound = "bluesmoke.ogg" end
  MESSAGE:New("REMARKING MY POSITION WITH  " .. smokecolor .. " SMOKE!", 15, ""):ToAll()

end

Check_aircraft_in_grids = SCHEDULER:New( nil, function()

    local TICCustomers = SET_GROUP:New():FilterCategoryHelicopter():FilterCategoryAirplane():FilterCoalitions("blue"):FilterOnce()
    local grid1 = ZONE:New(TICArea1)
    local grid2 = ZONE:New(TICArea2)
    local grid3 = ZONE:New(TICArea3)
    local TICAreaTable = {grid1, grid2, grid3}
    GoldTICFunctionsTable = {"GoldTICGrid1","GoldTICGrid2","GoldTICGrid3", }

    for i=1,#TICAreaTable do

      if TICCustomers:AnyInZone(TICAreaTable[i]) then
        _G[GoldTICFunctionsTable[i]]()
      end

    end

    flag4050 = USERFLAG:New("4050")
    flag4050:Set(0)

end, {}, onstation_time, onstation_time)

function LaseTarget(lcode)
   local TICgroupset = SET_GROUP:New():FilterCategoryAirplane():FilterCoalitions("blue"):FilterCategoryHelicopter():FilterStart()

   markgroupname = _G[tracermark_groupname]
   env.info("TICDEBUG: function TracerMark() " )
   env.info("TICDEBUG: markname: " .. _G[tracermark_groupname])
   markgroup = GROUP:FindByName(markgroupname)
   markgroup:OptionROEHoldFire()
   markgroup:OptionAlarmStateGreen()
   markgroupcoord = markgroup:GetCoordinate()
   
   if markgroupcoord:IsLOS(_G[FirePointCoord]) and _G[TICBaddieUnit1]:IsAlive() then
      --GROUP:isal
      --DEBUG _G[FirePointCoord]:MarkToAll("firepointcoord")
      --MESSAGE:New("Lase is possible, standby!"):ToAll()
      laserspot = SPOT:New(markgroup:GetUnit(1))
      laserspot:LaseOn(_G[TICBaddieUnit1],lcode,lasertime)
      --laserspot:LaseOnCoordinate(_G[FirePointCoord], 1688, 120)
      if laserspot:IsLasing() then
      TICgroupset:ForEachGroupCompletelyInZone(_G[TICZoneObject],function (grp)
              MESSAGE:New("Laser on, code " .. lcode ..  ", holding for " .. lasertime .. "  seconds!"):ToGroup(grp,TICMessageShowTime) end)             
      end
      
   else
      TICgroupset:ForEachGroupCompletelyInZone(_G[TICZoneObject],function (grp)
       MESSAGE:New("Negative Lase, unable.."):ToAll() end) 
        
    return
   end
   
end --function

function TracerMark()
   local TICgroupset = SET_GROUP:New():FilterCategoryAirplane():FilterCoalitions("blue"):FilterCategoryHelicopter():FilterStart()
   
   markgroupname = _G[tracermark_groupname]
   env.info("TICDEBUG: function TracerMark() " )
   env.info("TICDEBUG: markname: " .. _G[tracermark_groupname])
   markgroup = GROUP:FindByName(markgroupname)
   markgroup:OptionROEHoldFire()
   markgroup:OptionAlarmStateGreen()
      TICgroupset:ForEachGroupCompletelyInZone(_G[TICZoneObject],function (grp)                           
      --local deadsound = USERSOUND:New("weareCM2.ogg"):ToGroup(grp) 
        MESSAGE:New("Roger that, marking enemy direction with 50 cal!"):ToGroup(grp)      
       end)
     --end
     
    markTask = markgroup:TaskFireAtPoint(_G[FirePointVec2],1,25,nil,68)
    local fireStop = markgroup:TaskFunction("MarkGroupHoldFire")
    function MarkGroupHoldFire(grp) 
      grp:OptionROEHoldFire()
      env.info("TICDEBUG: HOLD FIRE!") 
      MESSAGE:New("TRACERS OUT, HOLDING FIRE... "):ToAll()
         
    end
          
    markgroup:SetTask(markTask,1)
    markgroup:SetTask(fireStop,15)

  end


if showTICmenu == true then
  local MenuCoalitionTopLevel = MENU_COALITION:New( coalition.side.BLUE, " Troops in Contact!" )
  TROOPSINCONTACTonL = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"TROOPS IN CONTACT LIGHT",MenuCoalitionTopLevel,TICsetflag, "light")
  TROOPSINCONTACTonH = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"TROOPS IN CONTACT HEAVY",MenuCoalitionTopLevel,TICsetflag, "heavy")
  NewSmoke = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"REQUEST NEW SMOKE",MenuCoalitionTopLevel,NewSmoke, "heavy")
  MarkTargetTracers = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"MARK TGT W/TRACERS",MenuCoalitionTopLevel,TracerMark, "")
  local MenuCoalitionLaser = MENU_COALITION:New( coalition.side.BLUE, "MARK TGT W/LASER", MenuCoalitionTopLevel)
  
  for i=1,#lasercode do
    MENU_COALITION_COMMAND:New( coalition.side.BLUE,"CODE: " .. lasercode[i] ,MenuCoalitionLaser,LaseTarget, lasercode[i])
  end
  
  SoundsOff = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"RADIO SOUNDS OFF",MenuCoalitionTopLevel,TICSounds, "false")
  SoundsOn = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"RADIO SOUNDS ON",MenuCoalitionTopLevel,TICSounds, "true")
  TROOPSINCONTACTcu = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"TIC Cleanup....",MenuCoalitionTopLevel,TICCleanup, "")
end
env.info("**** TROOPS IN CONTACT v10 by [BSD] FARGO LOADED ****")
