local ResourceDefinitions = {} -- ResourceDefinitions module
-- This module is used for loading, seting and retrieving game definitions
-- A image is an example of a game definition used, it has attributes like
-- width, height, and file path. 

-- All Game Definitions will be loaded in this table
local definitions = {}

------------------------------------------------
-- set ( string: name, table: attributes )
-- stores the attributes table using 'name' as
-- a key. This attributes can be retrieved using
-- the 'get' method with 'name' as parameter.
------------------------------------------------
function ResourceDefinitions:set(name, definition)
  
  -- 'name' is used to store 'definition'
  -- on the 'definitions' table.
  definitions[name] = definition
  
end

------------------------------------------------
-- setDefinitions ( table: definitions )
-- stores multiple definitions at once
------------------------------------------------
function ResourceDefinitions:setDefinitions(definitions)
  -- We iterate through all the definitions
  -- and then set them.
  for name, definition in pairs(definitions) do
    self:set(name, definition)
  end
  
end


------------------------------------------------
-- get ( string: name )
-- returns the resource definition for 'name'
------------------------------------------------
function ResourceDefinitions:get(name)
  
  -- 'name' is used to retrieve the resource
  -- definition from the 'definitions' table.
  return definitions[name]

end

------------------------------------------------
-- remove ( string: name )
-- removes the resource definition for 'name'
------------------------------------------------
function ResourceDefinitions:remove(name)
  
  -- setting the resource definition indexed 
  -- by 'name' to nil we eliminate it.
  -- and leave it in the hands of the
  -- garbage collector.
  definitions[name] = nil

end

------------------------------------------------
------------------------------------------------
------------------------------------------------

return ResourceDefinitions