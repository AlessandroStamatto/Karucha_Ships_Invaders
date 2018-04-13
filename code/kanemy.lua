local Kanemy = {} -- module Kanemy

local Japones = require "./code/japones" 
local ResourceManager = require "./code/resource_manager"
local Auxiliar = require "./code/auxiliar"

local kanaMeteors = {}
local lastTime = nil

local playerLife = startingLife
local currentLevel = 1
local notHit = false
local levelMaxHP = 100
--               
function Kanemy:initialize(lvl)
    lastTime = os.time()
    if notHit then
      playerLife = math.min(playerLife + 10, 150)
      startingLife = playerLife
    else
      playerLife = startingLife
    end
    currentLevel = lvl 
    notHit = true
    levelMaxHP = playerLife
    Japones:setupLevel(currentLevel)
    self.explosionSound = ResourceManager:get("explosionSound")
end

function Kanemy:updateLastTime()
  lastTime = os.time()
end

function Kanemy:makeInTime()
    local timeToWait = 6
    if gameSave["selected"] == "normal" then
        timeToWait = 4
    elseif gameSave["selected"] == "hard" then
        timeToWait = 2
    end
    if (os.time() - lastTime >= timeToWait) and not paused then
        Kanemy:new()
        lastTime = os.time()
    end
end

function Kanemy.Move(kanaMeteor)
  local kanaMeteorTimeSpeedBase = 9

  if gameSave["selected"] == "normal" then
    kanaMeteorTimeSpeedBase = 6
  elseif gameSave["selected"] == "hard" then
    kanaMeteorTimeSpeedBase = 3
  end

  local sz = #kanaMeteor.kana / 3

  local kanaMeteorTimeSpeed = kanaMeteorTimeSpeedBase + sz

  local ship, kana = kanaMeteor.shipProp, kanaMeteor
  if Japones:isBoss(kanaMeteor.kana) then
    kanaMeteorTimeSpeed = kanaMeteorTimeSpeed + sz
    kana = kanaMeteor.bossProp
  end
  local xh = math.random(LEFT + 10,RIGHT - 10)
  Auxiliar.setRot (ship, xh, BOT)
  local moveKanaAction = kana:seekLoc (xh, BOT, 1, kanaMeteorTimeSpeed, MOAIEaseType.LINEAR)
  local moveShipAction = ship:seekLoc (xh, BOT, 0, kanaMeteorTimeSpeed, MOAIEaseType.LINEAR)
  local actionGroup = MOAIAction.new()
  actionGroup:addChild(moveKanaAction)
  actionGroup:addChild(moveShipAction)

  local scaleKanaAction = kana:seekScl (0.25, 0.25, 1, kanaMeteorTimeSpeed, MOAIEaseType.LINEAR)
  local scaleShipAction = ship:seekScl (0.25, 0.25, 1, kanaMeteorTimeSpeed, MOAIEaseType.LINEAR)
  actionGroup:addChild(scaleKanaAction)
  actionGroup:addChild(scaleShipAction)

  actionGroup:start()
  --MOAIThread.blockOnAction (actionGroup)
  while actionGroup:isBusy() do
    if kanaMeteor.stop then
      actionGroup:stop()
      break
    end
    coroutine.yield()
  end
  if kanaMeteor.stop == false then
    Kanemy.destroy(kanaMeteor.kana, false)
  end
end

function Kanemy.Shake(kanaMeteor)
  
  local ship, kana = kanaMeteor.shipProp, kanaMeteor
  if Japones:isBoss(kanaMeteor.kana) then
    kana = kanaMeteor.bossProp
  end

  local angStep, timeStep = 10, 4

  local krx, kry, krz = kana:getRot() 
  local srx, sry, srz = ship:getRot()

  local shakeKanaAction = nil
  local shakeShipAction = nil
  local actionGroup = MOAIAction.new()
  local initialAngle = 0

  initialAngle = math.random (-angStep, angStep)

  kana:setRot(0,0, krz + initialAngle)
  ship:setRot(0,0, srz + initialAngle)

  while true do

    krx, kry, krz = kana:getRot() 
    srx, sry, srz = ship:getRot()

    shakeKanaAction = kana:seekRot(0,0,krz - angStep, timeStep)
    shakeShipAction = ship:seekRot(0,0,srz - angStep, timeStep)
    actionGroup = MOAIAction.new()
    actionGroup:addChild(shakeKanaAction)
    actionGroup:addChild(shakeShipAction)
    actionGroup:start()
    MOAIThread.blockOnAction (actionGroup)

    krx, kry, krz = kana:getRot() 
    srx, sry, srz = ship:getRot()

    shakeKanaAction = kana:seekRot(0,0,krz + angStep, timeStep)
    shakeShipAction = ship:seekRot(0,0,srz + angStep, timeStep)
    actionGroup = MOAIAction.new()
    actionGroup:addChild(shakeKanaAction)
    actionGroup:addChild(shakeShipAction)
    actionGroup:start()
    MOAIThread.blockOnAction (actionGroup)
  end

end

function Kanemy.Collision(kanaMeteor)

        local kana = kanaMeteor

        if Japones:isBoss(kanaMeteor.kana) then
          kana = kanaMeteor.bossProp
        end

        while true do
          if destroyAllKanas then
            Kanemy.destroy(kanaMeteor.kana)
            break
          end
          local kx, ky = kana:getLoc()
          if Auxiliar.insideCity(kx, ky) then
            playerLife = math.max(playerLife - 20, 0)
            notHit = false
            Kanemy.destroy(kanaMeteor.kana, true)
          end
          coroutine.yield()
        end
end

function Kanemy.destroy(kana, withSound)
    local kanaMeteor = kanaMeteors[kana]
    if withSound and gameSave["sound"] == 1 then
      Kanemy.explosionSound:play()
    end
    if kanaMeteor then
        kanaMeteor.moveThread:stop()
        kanaMeteor.collisionThread:stop()
        kanaMeteor.moveThread = nil
        kanaMeteor.collisionThread = nil
        Japones:addKana (kana)
        kanaMeteors[kanaMeteor.kana] = nil
        midLayer:removeProp(kanaMeteor)
        midLayer:removeProp(kanaMeteor.shipProp)
        if (kanaMeteor.bossProp) then
          midLayer:removeProp(kanaMeteor.bossProp)
        end

        if not kanaMeteor.shipProp.rotate then
          kanaMeteor.shakeThread:stop()
          kanaMeteor.shakeThread = nil
        end
    end
end

function Kanemy:getKanaProp(kana)
  return kanaMeteors[kana]
end

function Kanemy:currentLife()
  return playerLife
end

function Kanemy:maxHP()
  return levelMaxHP
end

function Kanemy:endLevel()
  destroyAllKanas = true
end

function Kanemy:startLevel()
  destroyAllKanas = false
end

function Kanemy:new ()
  local kanaMeteor = MOAITextBox.new()
  kanaMeteor:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
  kanaMeteor:setFont(kanjiFont)
  kanaMeteor:setYFlip(true)
  kanaMeteor.kana = Japones:randomKana(kanaMeteor)
  kanaMeteor.stop = false
  if not kanaMeteor.kana then
    kanaMeteor = nil
    return
  end

  local sz = #kanaMeteor.kana / 3
  kanaMeteor:setString(kanaMeteor.kana)

  kanaMeteor:setRect(-28 * sz, -28, 28 * sz, 28)

  kanaMeteor:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
  print (Japones:kanaToText(kanaMeteor.kana))
  local kx, ky = math.random(LEFT,RIGHT), TOP
  kanaMeteor:setLoc (kx, ky, 1)
  kanaMeteors[kanaMeteor.kana] = kanaMeteor
  kanaMeteor.shipProp = MOAIProp.new ()
  kanaMeteor.shipProp:setLoc (kx, ky, 0)
  midLayer:insertProp (kanaMeteor.shipProp)
  midLayer:insertProp (kanaMeteor)

  if Japones:isBoss(kanaMeteor.kana) then
    kanaMeteor.shipProp:setDeck ( ResourceManager:get ( "paraquedas" ) )
    kanaMeteor.shipProp.rotate = false
    kanaMeteor:setString("  ")
    kanaMeteor.bossProp = MOAIProp.new ()
    kanaMeteor.bossProp:setDeck ( ResourceManager:get ( Japones:kanaToText(kanaMeteor.kana) ) )
    kanaMeteor.bossProp:setLoc (kx, ky, 1)
    kanaMeteor.bossProp:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
    midLayer:insertProp (kanaMeteor.bossProp)
  else
    kanaMeteor.shipProp:setDeck ( ResourceManager:get ( "ship" ) )
    kanaMeteor.shipProp.rotate = true
  end

  kanaMeteor.shipProp:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )

  kanaMeteor.moveThread = MOAIThread.new()
  kanaMeteor.moveThread:run (Kanemy.Move, kanaMeteor)
  kanaMeteor.collisionThread = MOAIThread.new()
  kanaMeteor.collisionThread:run (Kanemy.Collision, kanaMeteor)

  if not kanaMeteor.shipProp.rotate then
    kanaMeteor.shakeThread = MOAIThread.new()
    kanaMeteor.shakeThread:run (Kanemy.Shake, kanaMeteor)
  end

end

function sleep ( time )
  local st = os.time()
  while (os.time() - st < time) do
    coroutine.yield()
  end
end

return Kanemy