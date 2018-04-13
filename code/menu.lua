local Menu =  {} -- The Menu module

-- Imports
local ResourceManager = require "./code/resource_manager"
local ResourceDefinitions = require "./code/resource_definitions"
local Mouse = require "./code/mouse"
local Saves = require "./code/saves"

-- Module variables
local onMenu = true
local menuOptions = {}
local processInputFunction = function () end
local onOption = "Main"

function Menu:start ()
  -- Do the initial setup
  self:initialize ()
  while ( onMenu ) do
    self:processInput()
    self:checkSound()
    coroutine.yield()
  end
  self.menuSound:stop()
end

function Menu:checkSound ()
    if gameSave["sound"] == 0 and (soundStopped == false) then
        self.menuSound:stop()
        soundStopped = true
    elseif gameSave["sound"] == 1 and (soundStopped == true) then
        self.menuSound:play()
        soundStopped = false
        print ("play")
    end
end
------------------------------------------------
-- initialize ( )
-- does all the initial setup for the game
------------------------------------------------
function Menu:initialize ()

  onMenu = true

  local savedTable, err = Saves.load("./saves/achievements.sav")
  if err == nil then
    achieved = savedTable
    print ("Sucessfully loaded achievements!")
  end

  savedTable, err = Saves.load("./saves/game.sav")
  if err == nil then
    gameSave = savedTable
    print ("Sucessfully loaded game save!")
  end  

  -- We load all our resources
  ResourceDefinitions:setDefinitions ( resource_definitions )
  kanjiFont = ResourceManager:get ( "kanjiFont" )

  MOAIRenderMgr.setRenderTable ( nil )

  -- layer initialization
  backgroundLayer = MOAILayer2D.new ()
  backgroundLayer:setViewport ( viewport )

  midLayer = MOAILayer2D.new ()
  midLayer:setViewport ( viewport )

  hudLayer = MOAILayer2D.new ()
  hudLayer:setViewport ( viewport )

  storyLayer = MOAILayer2D.new ()
  storyLayer:setViewport (viewport)

  self:loadBackground ()

  MOAIRenderMgr.setRenderTable ( { backgroundLayer, midLayer, hudLayer, storyLayer} )

  Mouse:initialize()

  self.menuSound = ResourceManager:get("backgroundMusic")
  self.menuSound:play()

  processInputFunction = mainMenuInput

end

function Menu:newOption (name, y, x)
    if x == nil then x = 500 end
    menuOptions[name] = MOAIProp2D.new ()
    menuOptions[name]:setDeck ( ResourceManager:get ( "hitbox" ) )
    setWinPos (menuOptions[name], x, y)
    hudLayer:insertProp ( menuOptions[name] )
end

function Menu:loadBackground ()
    self.backgroundProp = MOAIProp2D.new ()
    self.backgroundProp:setDeck ( ResourceManager:get ( "menuBackground" ) )
    backgroundLayer:insertProp ( self.backgroundProp )
    Menu:loadMainMenuOptions()

end

function Menu:unloadMenuOptions ()
    for _ , prop in pairs(menuOptions) do
      hudLayer:removeProp(prop)
    end
end

function Menu:loadMainMenuOptions ()

    Menu:newOption ("Start", 163)
    Menu:newOption ("Top10", 240)
    Menu:newOption ("Achievements", 290)
    Menu:newOption ("Configurations", 340)
    Menu:newOption ("Help", 396)
    Menu:newOption ("About", 445)

end

function Menu:loadMenuScreen (screenName)
    self.screenProp = MOAIProp2D.new ()
    self.screenProp:setDeck ( ResourceManager:get ( screenName ) )
    midLayer:insertProp ( self.screenProp )
    Menu:unloadMenuOptions()

    Menu:newOption ("Back", 25, 400)
    processInputFunction = screenMenuInput

    onOption = screenName

end

function Menu:prepareConfigScreen ()
    soundOnProp = MOAIProp2D.new()
    soundOnProp:setDeck (ResourceManager:get("unselected"))
    soundOnProp:setLoc (-63, 224)
    hudLayer:insertProp (soundOnProp)

    soundOffProp = MOAIProp2D.new()
    soundOffProp:setDeck (ResourceManager:get("unselected"))
    soundOffProp:setLoc (46, 224)
    hudLayer:insertProp (soundOffProp)

    if gameSave["sound"] == 1 then
        soundOnProp:setDeck (ResourceManager:get("selectedGreen"))
    elseif gameSave["sound"] == 0 then
        soundOffProp:setDeck (ResourceManager:get("selectedGreen"))
    end 
end

function Menu:unprepareConfigScreen ()
    if (soundOffProp ~= nil) then
        hudLayer:removeProp (soundOffProp)
    end
    if (soundOnProp ~= nil) then
        hudLayer:removeProp (soundOnProp)
    end
end

function Menu:unprepareLevelScreen ()
    if easyProp ~= nil then
        hudLayer:removeProp (easyProp)
        hudLayer:removeProp (mediumProp)
        hudLayer:removeProp (hardProp)

        for _, prop in ipairs (levelsProp) do
            hudLayer:removeProp (prop)
        end
    end
end

function Menu:prepareLevelScreen ()

    easyProp = MOAIProp2D.new()
    easyProp:setDeck (ResourceManager:get("unselected"))
    easyProp:setLoc (-159, 222)
    hudLayer:insertProp (easyProp)

    mediumProp = MOAIProp2D.new()
    mediumProp:setDeck (ResourceManager:get("unselected"))
    mediumProp:setLoc (1, 222)
    hudLayer:insertProp (mediumProp)

    hardProp = MOAIProp2D.new()
    hardProp:setDeck (ResourceManager:get("unselected"))
    hardProp:setLoc (120, 222)
    hudLayer:insertProp (hardProp)

    if gameSave["selected"] == "easy" then
        easyProp:setDeck (ResourceManager:get("selectedRed"))
    elseif gameSave["selected"] == "medium" then
        mediumProp:setDeck (ResourceManager:get("selectedRed"))
    else
        hardProp:setDeck (ResourceManager:get("selectedRed"))
    end 

    levelsProp = {}
    local difficulty = gameSave["selected"]
    for i=1, gameSave[ difficulty ] do
      levelsProp[i] = MOAIProp2D.new()
      levelsProp[i]:setDeck (ResourceManager:get ("levelShip"))
      local x = 170 + (math.ceil (i/3))*60
      local md = i % 3; if md == 0 then md = 3 end
      local y =  263 + md * 37
      local wx, wy = hudLayer:wndToWorld (x, y)
      if i > 15 then wx = wx + 20 end
      levelsProp[i]:setLoc (wx, wy)
      levelsProp[i]:setScl (1.1, 1.1)
      hudLayer:insertProp (levelsProp[i])
    end
end

------------------------------------------------
-- processInput  ( )
-- talks to InputManager to handle input
------------------------------------------------
function Menu:processInput ()
    processInputFunction()
end

function mainMenuInput ()
  if Mouse:click() then
    if Mouse:onProp (menuOptions["Start"]) then
        Menu:loadMenuScreen("levels")
        Menu:prepareLevelScreen()
    elseif Mouse:onProp (menuOptions["Configurations"]) then
        Menu:loadMenuScreen("configurations")
        Menu:prepareConfigScreen()
    elseif Mouse:onProp (menuOptions["Achievements"]) then
        Menu:loadMenuScreen("achievements")
        for name, value in pairs (achieved) do
          if (value==1) then print (name) end
        end
    elseif Mouse:onProp (menuOptions["Top10"]) then
        Menu:loadMenuScreen("top10")
    elseif Mouse:onProp (menuOptions["About"]) then
        Menu:loadMenuScreen("about")
    elseif Mouse:onProp (menuOptions["Help"]) then
        Menu:loadMenuScreen("help")
    end
    
    print (Mouse:position())
  end
end

function notInArea ()
    local wx, wy = Mouse:worldPosition()
    ylimit = -100
    if onOption == "configurations" then ylimit = 100 end
    return (wx < -328 or wx > 328 or wy < ylimit)
end

function showStory (n)
    storyScreen = MOAIProp2D.new ()
    storyScreen:setDeck (ResourceManager:get( tostring(n) .. "_1"))
    storyScreen:setLoc (0, 0)

    storyLayer:insertProp(storyScreen)

    local part = 1
    while part < 6 do
        if Mouse:click () then
           part = part + 1
           storyScreen:setDeck (ResourceManager:get( tostring(n) .. "_" .. tostring(part)))
        end
        coroutine.yield()
    end

    onMenu = false
end



function screenMenuInput ()
  if Mouse:click() then
    if (Mouse:onProp (menuOptions["Back"])) or (notInArea()) then
        midLayer:removeProp (Menu.screenProp)
        Menu:unloadMenuOptions()
        Menu:unprepareLevelScreen()
        Menu:unprepareConfigScreen ()
        Menu:loadMainMenuOptions()
        onOption = "Main"
        processInputFunction = mainMenuInput
    end

    if (levelsProp ~= nil and onOption == "levels") then
        for i, prop in ipairs (levelsProp) do
          if Mouse:onProp (prop) then
            startLevelParameter = i
            if startLevelParameter == 1 then
              showStory (1)
            else
              onMenu = false
            end
            break
          end
        end
    end

    if Mouse:onProp (easyProp) then
        gameSave["selected"] = "easy"
        Menu:unprepareLevelScreen()
        Menu:prepareLevelScreen()
    elseif Mouse:onProp (mediumProp) then
        gameSave["selected"] = "medium"
        Menu:unprepareLevelScreen()
        Menu:prepareLevelScreen()
    elseif Mouse:onProp (hardProp) then
        gameSave["selected"] = "hard"
        Menu:unprepareLevelScreen()
        Menu:prepareLevelScreen()
    end

    if onOption == "configurations" then
        if Mouse:onProp (soundOffProp) then
            gameSave["sound"] = 0
            Menu:unprepareConfigScreen ()
            Menu:prepareConfigScreen ()
        elseif Mouse:onProp (soundOnProp) then
            gameSave["sound"] = 1
            Menu:unprepareConfigScreen ()
            Menu:prepareConfigScreen ()
        end
    end

    print (Mouse:worldPosition())
  end
    
end
------------------------------------------------
-- sleepCoroutine  ( time )
-- helper method to freeze the thread for 
-- 'time' seconds.
------------------------------------------------
function sleepCoroutine ( time )
  local timer = MOAITimer.new ()
  timer:setSpan ( time )
  timer:start ()
  MOAICoroutine.blockOnAction ( timer )
end

function sleep ( time )
  local st = os.time()
  while (os.time() - st < time) do
    coroutine.yield()
  end
end


return Menu