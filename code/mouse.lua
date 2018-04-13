local Mouse = {} -- Mouse module
----------------------------------------------------------------
-- Kana invaders
-- Alessandro Stamatto & Juvane Nunes
----------------------------------------------------------------

-- Mouse states, updated every frame 
local previousX, previousY = 0, 0
local pointerX, pointerY = 0, 0
local clicking = false

-- Sets mouse callback 
function Mouse:initialize ()

    if MOAIInputMgr.device.pointer then
        -- Function (callback) to handle mouse input:
        local pointerCallback = function ( x, y )
            previousX, previousY = pointerX, pointerY
            pointerX, pointerY = x, y

            if touchCallbackFunc then
            touchCallbackFunc ( MOAITouchSensor.TOUCH_MOVE, 1, pointerX, pointerY, 1 )
            end
        end
        MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
    end
end

-- Returns true if a mouse click occured and was not handled yet
function Mouse:click()
    if self:isDown() and not clicking then
        clicking = true
        return true
    else
        clicking = self:isDown()
        return false
    end
end 

-- Returns true if the mouse button is currently down
function Mouse:isDown ()
    if MOAIInputMgr.device.touch then
        return MOAIInputMgr.device.touch:isDown ()
    elseif MOAIInputMgr.device.pointer then
        return (MOAIInputMgr.device.mouseLeft:isDown ())
    end
end

-- Returns the current mouse WINDOW position
function Mouse:position ()
    return pointerX, pointerY
end

-- Returns the current mouse WORLD position
function Mouse:worldPosition ()
    local mouseX, mouseY = hudLayer:wndToWorld(pointerX, pointerY)
    return mouseX, mouseY
end

-- Returns true if the mouse is inside of a game element (prop)
function Mouse:onProp(prop)
  if prop == nil then return false end
  local worldX, worldY = hudLayer:wndToWorld (Mouse:position())
  return prop:inside(worldX, worldY)
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
return Mouse