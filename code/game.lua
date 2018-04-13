local Game =  {}

-- Imports all Game modules
local ResourceManager = require "./code/resource_manager"
local Japones = require "./code/japones"
local ResourceDefinitions = require "./code/resource_definitions"
local Kanemy = require "./code/kanemy"
local Aux = require "./code/auxiliar"
local Mouse = require "./code/mouse"
local Saves = require "./code/saves"

-- Module variables
local startTime = 0
local gameLevel = startLevelParameter
local gameOver = false
local oldMaxHP = 100

------------------------------------------------
-- start ( )
-- initializes the game. this should be
-- called from main.lua
------------------------------------------------
function Game:start ()

  -- Do the initial setup
  self:initialize ()
  
  -- Game Loop
  while ( true ) do -- [Game Loop] start
    -- Start the current level
    self:startLevel(gameLevel)
    
    while ( true ) do -- [Level Loop] start
      self:makeKanemies()  -- Generates new kanas (kanemies)
      self:processInput () -- Handles current input
      self:showLevel ()    -- Render the "level: X" string

      if self:zeroLife () then -- Render the current life, and checks if it's 0 
        self:processGameOver() -- If it's zero, it's game over
        break                  -- Exit the Level Loop 
      end

      if self:zeroTime () then -- Render the remaining time, and checks if it's 0     
        self:processLevelComplete() -- If it's zero, the level is complete (over)
        break                       -- Exit the Level Loop
      end
      coroutine.yield () -- Gives MOAI time to update things   

      if paused then -- checks the game pause status
        pauseTheGame() -- if pause is On (true), call the pausing function
      end
    end -- [Level Loop] end

    -- Checks if we should exit the Game Loop
    if gameOver or gameLevel == 31 then -- If it's game over, or all levels completed...
      self.levelTheme:stop() -- stop the game music
      sleep (2)              -- wait a little (2 seconds)
      break                  -- and EXIT the Game Loop 
    end

  end -- [Game Loop] end

end

-- Render the menu at the end of each level
-- With the "Victory" string, and next/retry buttons
function Game:processLevelComplete()
  self.timerInNumber:setString("00") -- changes time string to two zeros
  Game:showGameMsg("Victory", 0, 100, 0) -- Renders the string in Green
  Game:showButtons() -- shows next/retry buttons           
  Kanemy:endLevel()  -- end current level

  Saves.save (achieved, "./saves/achievements.sav")

  local difficulty = gameSave["selected"]
  if gameLevel == gameSave[difficulty] then
    gameSave[difficulty] = gameLevel + 1
    Saves.save (gameSave, "./saves/game.sav")
  end

  local notChoosen = true
  while notChoosen do
    if Mouse:click() then
      if Mouse:onProp (self.nextLevel) then
        gameLevel = gameLevel + 1
        notChoosen = false
      elseif Mouse:onProp (self.replayLevel) then
        gameLevel = gameLevel
        notChoosen = false
      end
    end
    coroutine.yield()
  end

end

function Game:processGameOver()
  self.lifeInNumber:setString("00")
  Game:showGameMsg("Game Over", 100, 0, 0)
  Kanemy:endLevel()
  gameOver = true
  self.levelTheme:stop()
end

------------------------------------------------
-- initialize ( )
-- does all the initial setup for the game
------------------------------------------------
function Game:initialize ()

  startTime = 0
  gameLevel = startLevelParameter
  gameOver = false
  dMode = gameSave["selected"]

  -- We load all our resources
  ResourceDefinitions:setDefinitions ( resource_definitions )
  
  -- Initialize fonts
  self:initializeFonts()

  -- Initialize input/Japonese manager
  Japones:initialize ()

  self.shotSound = ResourceManager:get("shotSound")
  self.levelTheme = ResourceManager:get("levelTheme")
  self.bonusSound = ResourceManager:get("bonusSound")

  if gameSave["sound"] == 1 then
    self.levelTheme:play()
  end

end

function Game:initializeFonts ()
  kanjiFont    = ResourceManager:get ( "kanjiFont" )
  hudFont      = ResourceManager:get ( "hudFont" )
  numbersFont  = ResourceManager:get ( "numbersFont" )
  textFont     = ResourceManager:get ( "textFont" )
end

function Game:startLevel (lvl)

  MOAIRenderMgr.setRenderTable ( nil )

  -- First of all, we start all layers
  backgroundLayer = MOAILayer2D.new ()
  backgroundLayer:setViewport ( viewport )
  
  -- midLayer
  midLayer = MOAILayer2D.new()
  midLayer:setViewport (viewport)

  -- HUD layer
  hudLayer = MOAILayer2D.new ()
  hudLayer:setViewport ( viewport )

  self:loadBackground ()
  self:loadHud()

  -- Initialize Kanemy module
  Kanemy:initialize(lvl)

  Game:initializeLife()
  Game:initializeTimer()
  Game:initializeLevel()
  Game:initializeEndMsg()
  Game:initializeBonus()
  Game:initializeButtons()

  MOAIRenderMgr.setRenderTable ( { backgroundLayer, midLayer, hudLayer } )

  Game:hideGameMsg()
  Kanemy.startLevel()
end

function Game:initializeBonus()
  self.bonus = MOAIProp2D.new ()
  self.bonus:setDeck ( ResourceManager:get ( "bonus" ) )  
  setDefaultPos (self.bonus, "bonus")
  self.bonus:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
  self.bonus:setColor(1,1,1,0)
  hudLayer:insertProp ( self.bonus )
end

function Game:initializeButtons()
  self.nextLevel = MOAIProp2D.new ()
  self.nextLevel:setDeck ( ResourceManager:get ( "nextLevel" ) )  
  setDefaultPos (self.nextLevel, "nextLevel")
  self.nextLevel:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
  self.nextLevel:setColor(1,1,1,0)
  hudLayer:insertProp ( self.nextLevel )

  self.replayLevel = MOAIProp2D.new ()
  self.replayLevel:setDeck ( ResourceManager:get ( "replayLevel" ) )  
  setDefaultPos (self.replayLevel, "replayLevel")
  self.replayLevel:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
  self.replayLevel:setColor(1,1,1,0)
  hudLayer:insertProp ( self.replayLevel )
end

function Game:showBonus ()
  if (self.bonus) then
    if gameSave["sound"] == 1 then
      Game.bonusSound:play()
    end
    self.bonus.thread = MOAIThread.new()
    self.bonus.thread:run (Game.bonusAlpha, self.bonus)
  else
    print ("Bonus prop not found!")
  end
end

function Game:showButtons ()
  self.nextLevel:setColor (1, 1, 1, 1)
  self.replayLevel:setColor (1, 1, 1, 1)
end


function Game.bonusAlpha (lprop)
  MOAIThread.blockOnAction ( lprop:seekColor (1, 1, 1, 1, 1, MOAIEaseType.LINEAR) )
  sleep (1)
  MOAIThread.blockOnAction ( lprop:seekColor (1, 1, 1, 0, 1, MOAIEaseType.LINEAR) )
  lprop.thread:stop()
end

function Game:showGameMsg(message, color_r, color_g, color_b)
  self.endMsg:setLoc(15, TOP - 200)
  self.endMsg:setColor(color_r, color_g, color_b)
  self.endMsg:setString(message)
end

function Game:hideGameMsg()
  self.endMsg:setLoc(RIGHT + 10, TOP + 10)
  self.endMsg:setString("")
end

function Game:initializeEndMsg()
  self.endMsg = MOAITextBox.new()
  self.endMsg:setFont(kanjiFont)
  self.endMsg:setYFlip(true)
  self.endMsg:setRect(-250,-60,250,60)
  self.endMsg:setLoc(RIGHT + 10, TOP + 10)
  self.endMsg:setColor(0, 0, 0)
  self.endMsg:setString("teste")
  Aux.centralize(self.endMsg)
  midLayer:insertProp (self.endMsg)
end


function Game:initializeLife()

  self.barra = MOAIProp2D.new ()
  self.barra:setDeck ( ResourceManager:get ( "barra" ) )  
  setDefaultPos (self.barra, "barra")
  hudLayer:insertProp ( self.barra )

  self.lifeInNumber = MOAITextBox.new()
  self.lifeInNumber:setFont(numbersFont)
  self.lifeInNumber:setYFlip(true)
  self.lifeInNumber:setRect(-75,-35,75,35)
  Aux.centralize(self.lifeInNumber)
  hudLayer:insertProp (Game.lifeInNumber)

end

function Game:initializeTimer()
  self.timerInNumber = MOAITextBox.new()
  self.timerInNumber:setFont(numbersFont)
  self.timerInNumber:setYFlip(true)
  self.timerInNumber:setRect(-115,-50,115,50)
  Aux.centralize(Game.timerInNumber)
  hudLayer:insertProp (Game.timerInNumber)
  startTime = os.time()
  self.currentTime = timeOnEachLevel
end

function Game:initializeLevel()
  self.levelInNumber = MOAITextBox.new()
  self.levelInNumber:setFont(numbersFont)
  self.levelInNumber:setYFlip(true)
  self.levelInNumber:setRect(-50,-50,50,50)
  Aux.centralize(self.levelInNumber)
  hudLayer:insertProp (Game.levelInNumber)

  self.levelText = MOAITextBox.new()
  self.levelText:setFont(textFont)
  self.levelText:setYFlip(true)
  self.levelText:setRect(-150,-50,150,50)
  Aux.centralize(self.levelText)
  hudLayer:insertProp (Game.levelText)

  self.modeText = MOAITextBox.new()
  self.modeText:setFont(textFont)
  self.modeText:setYFlip(true)
  self.modeText:setRect(-150,-50,150,50)
  Aux.centralize(self.modeText)
  hudLayer:insertProp (Game.modeText)
end

function Game:zeroLife()
  local current = Kanemy:currentLife()
  local total = Kanemy:maxHP()
  if total > oldMaxHP then
    self:showBonus()
    oldMaxHP = total
  end 
  local tx = "" .. current
  local xOffset = (1 - current/total)/2
  --self.lifeInNumber:setString(tx)
  self.lifeInNumber:setColor ( 0, 0, 0)
  self.lifeInNumber:setLoc ( LEFT + 10 , TOP - 50)
  
  self.barra:setScl (current/total, 1, 1)
  self.barra:setLoc (self.barra.defaultX  - (xOffset * barWidth), self.barra.defaultY)
  return Kanemy:currentLife() < 1
end

function Game:zeroTime()
  local tx = ""
  self.secs = math.floor (self.currentTime - (os.time() - startTime))
  tx = tx .. self.secs
  if #tx == 1 then
    tx = "0" .. tx
  end
  self.timerInNumber:setString(tx)
  self.timerInNumber:setColor ( 0.376, 0.376, 0.384)
  setWinPos (self.timerInNumber, 514, 35)
  return self.secs <= 0
end

function Game:showLevel()
  local tx = ""
  tx = tx .. gameLevel
  self.levelInNumber:setString(tx)
  self.levelInNumber:setColor ( 0.502, 0.510, 0.5215)
  setWinPos(self.levelInNumber, 840, 35)

  self.levelText:setString("level")
  self.levelText:setColor ( 0.502, 0.510, 0.5215)
  setWinPos(self.levelText, 780, 25)

  self.modeText:setString(dMode)
  self.modeText:setColor ( 0.502, 0.510, 0.5215)
  if dMode == "easy" then
    setWinPos(self.modeText, 640, 20)
  else
    setWinPos(self.modeText, 640, 25)
  end
end

function Game:loadBackground ()
    local prop = MOAIProp2D.new ()
    local dk = nil
    print ("Level: " .. gameLevel)
    currentDk = math.floor((gameLevel-1)/3) % 3
    if currentDk == 0 then
      dk = ResourceManager:get ( "manha" )
    elseif currentDk == 1 then
      dk = ResourceManager:get ( "tarde" )
    elseif currentDk == 2 then
      dk = ResourceManager:get ( "noite" )
    end
    prop:setDeck (dk)
    setDefaultPos(prop, "manha") -- tanto faz aqui, manha/tarde/noite = mesmo tamanho
    self.cannon = MOAIProp.new ()
    self.cannon:setDeck(ResourceManager:get ("cannon"))
    setDefaultPos(self.cannon, "cannon")
    self.cannon.rotate = true
    backgroundLayer:insertProp ( prop )
    backgroundLayer:insertProp (self.cannon)
end

function Game:loadHud ()
    local prop = MOAIProp2D.new ()
    local hudDK = ResourceManager:get("hud")
    prop:setDeck (hudDK)
    setDefaultPos(prop, "hud")
    hudLayer:insertProp ( prop )
end

------------------------------------------------
-- processInput  ( )
-- talks to InputManager to handle input
------------------------------------------------
function Game:processInput ()
  local kn = Japones:getKana()
  if kn then
    Game:newLaser(kn)
  end

  if Mouse:click() then
    lx, ly = Mouse:position()
    print (midLayer:wndToWorld(lx, ly))
  end
end

function Game:makeKanemies ()
  Kanemy:makeInTime()
end

function Game:newLaser (kn)
  local laserProp = MOAIProp.new ()
  laserProp:setDeck ( ResourceManager:get ( "raio" ) )
  local lx, ly = self.cannon:getLoc()
  laserProp:setLoc (lx, ly, 1)
  laserProp.target = kn
  laserProp.rotate = true
  midLayer:insertProp(laserProp)
  laserProp.thread = MOAIThread.new()
  laserProp.thread:run (Game.laserShot, laserProp)
end

function Game.laserShot (lprop)
  local laserSpeed = 1.5
  local kanaMeteor = Kanemy:getKanaProp(lprop.target)
  local capturaProp = MOAIProp.new ()
  if kanaMeteor then
    if gameSave["sound"] == 1 then
      Game.shotSound:play()
    end

    local kana = kanaMeteor
    if Japones:isBoss(kanaMeteor.kana) then
      kana = kanaMeteor.bossProp
    end

    kanaMeteor.stop = true

    local tx, ty = kana:getLoc()
    local lx, ly = lprop:getLoc()
    
    local dist = Aux.distance (lx, ly, tx, ty)
    local lScale = dist/525

    lprop:setScl (1, lScale, 1)

    Aux.setRot (Game.cannon, tx, ty)
    Aux.setRot (lprop, tx, ty)

    capturaProp:setDeck ( ResourceManager:get ( "capturaNave" ) )
    capturaProp:setLoc (tx, ty, 1)
    local sx, sy, sz = kana:getScl()
    capturaProp:setScl (sx, sy, sz)
    midLayer:insertProp (capturaProp)

    MOAIThread.blockOnAction ( lprop:seekColor (1, 1, 1, 0, 0.25, MOAIEaseType.LINEAR) )
    midLayer:removeProp(lprop)

    local actionGroup = MOAIAction.new()
    local fadeCircle = capturaProp:seekColor (1, 1, 1, 0, 0.5, MOAIEaseType.LINEAR)
    local fadeKana   = kana:seekColor (1, 1, 1, 0, 0.5, MOAIEaseType.LINEAR)
    local fadeShip   = kanaMeteor.shipProp:seekColor (1, 1, 1, 0, 0.5, MOAIEaseType.LINEAR)
    
    actionGroup:addChild(fadeCircle)
    actionGroup:addChild(fadeKana)
    actionGroup:addChild(fadeShip)

    actionGroup:start()
    MOAIThread.blockOnAction(actionGroup)

    Kanemy.destroy(kanaMeteor.kana, true)
  end
  midLayer:removeProp(capturaProp)
  lprop.thread:stop()
  midLayer:removeProp(lprop)
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

function pauseTheGame()
  Game.oldRoot = MOAIActionMgr.getRoot () -- get the root 
  MOAIActionMgr.setRoot () -- clear out the old root; will be automatically recreated
  Game.levelTheme:pause()
  paused = true
  MOAIInputMgr.device.keyboard:setCallback(
    function(key,down)
        if down==true then
            -- If a non letter key is pressed
            -- we check if it forms a Kana, and
            -- then resets the input buffer
            if (key == 27) then
              unpauseTheGame()
            end
        end
    end
    )
end

function unpauseTheGame()
  MOAIActionMgr.setRoot (Game.oldRoot)
  Japones:initialize ()
  if gameSave["sound"] == 1 then
    Game.levelTheme:play()
  end
  startTime = os.time()
  Game.currentTime = Game.secs
  paused = false
  Kanemy:updateLastTime()
end

return Game
