require "./code/config" -- read Config 
require "./code/globalVars" -- read Global variables
local Menu   = require "./code/menu" 
local Game   = require "./code/game"

-- Open main screen
MOAISim.openWindow ( "Karucha Ships Invaders", ScreenX, ScreenY )

-- Setup viewport
viewport = MOAIViewport.new ()
viewport:setSize ( ScreenX, ScreenY )
viewport:setScale ( WorldX, WorldY )

function mainLoop ()
    MOAIUntzSystem.initialize() -- start sound system 
    while (true) do
        Menu:start ()
        Game:start ()
    end
end

gameThread = MOAICoroutine.new ()
gameThread:run ( mainLoop )
