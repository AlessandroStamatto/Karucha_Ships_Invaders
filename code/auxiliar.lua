local Auxiliar = {} -- Auxiliar module
----------------------------------------------------------------
-- Alessandro Stamatto & Juvane Nunes
----------------------------------------------------------------

-- Auxilar functions

-- Returns the angle beetween the vector (x2-x1, y2-y1) and the X axis
function Auxiliar.angle (x1, y1, x2, y2)
	return math.atan2 (y2 - y1, x2 - x1) * (180/math.pi)
end

-- Rotates a game element (prop) to face a point (x2, y2)
function Auxiliar.setRot (prop, x2, y2)
	local x1, y1 = prop:getLoc()
	local ang = math.atan2 (y2 - y1, x2 - x1) * (180/math.pi)
	ang = ang - 90 --offset
	if prop.rotate then
		prop:setRot(0, 0, ang)
	else
		prop:setRot(0,0, 180)
	end
end

-- Returns the distance beetween point A (x1, y1) and point B (x2, y2)
function Auxiliar.distance (x1, y1, x2, y2)
	return math.sqrt( ((x2 - x1) ^2) + ((y2 - y1) ^ 2) )
end

-- (City colision function)
-- Returns true if there's a colision beetween xw,yw and the city
-- xw and yw are in World Coordinates
-- (Currently using an elipse as an approximation of the city/force-field geometry)
function Auxiliar.insideCity (xw, yw)
	x, y = hudLayer:worldToWnd(xw, yw)
	local h, k = 507, 640 -- Elipse center
	local rx, ry = 268, 171 -- Elipse radius
	local rx2 = rx * rx -- square of rx
	local ry2 = ry * ry -- square of ry
	local x_h2 = (x - h) * (x - h)
	local y_h2 = (y - k) * (y - k)
	return (x_h2 / rx2) + (y_h2 / ry2) <= 1
end

-- centralizes the text inside a text box
function Auxiliar.centralize(prop)
	prop:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
end

-- Bound colision algorithm beetween the object and the target
function Auxiliar.boundCollision (object, target)
	
	objectX, objectY = object:getLoc()
	targetX, targetY = target:getLoc()
	
	--print (objectX .. " " .. objectY .. " " .. targetX .. " " .. targetY .. " " .. objectWidth .. " " .. objectHeigth .. " " .. targetWidth .. " " .. targetHeigth)

	objectRight = objectX + objectWidth objectLeft = objectX - objectWidth
	objectTop = objectY + objectHeigth objectBottom = objectY - objectHeigth
	targetRight = targetX + targetWidth targetLeft = targetX - targetWidth
	targetTop = targetY + targetHeigth targetBottom = targetY - targetHeigth

	objectOutsideTop = objectBottom > targetTop
	objectOutsideBottom = objectTop < targetBottom
	objectOutsideRight = objectLeft > targetRight
	objectOutsideLeft  = objectRight < targetLeft

	return not (objectOutsideLeft or objectOutsideRight or objectOutsideBottom or objectOutsideTop)
end

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
return Auxiliar