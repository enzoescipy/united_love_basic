local linear = require "united_love.packages.linear"
--
-- gameobj
-- 
-- where gameobj are decleared.
--

Main = require "test_gameobjList"

-- :warning! Cashing 
--main tdthe component like "trans = gameobj.transform" or "j" to referencing
-- component obj = gameobof some object easily and NOT DELETING cashed variables like "trans = nil" can
-- cause MEMORY LEAK. DO delete cashed vars after using it.
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nil"


Banana = GameObject:find("Banana")
Camera = GameObject:find("Camera")
function love.load()
  Graphics.setWindowSize(1024,640)
end

function love.update(dt)
  
  if love.keyboard.isDown("up") == true then
    Camera.transform:changevar("pos_abs", linear.vectorAdd(Camera.transform.pos_abs,linear.vectorScaling(Camera.transform.tMatrix.yVector,-500*dt)))
  elseif love.keyboard.isDown("down") == true then
    Camera.transform:changevar("pos_abs", linear.vectorAdd(Camera.transform.pos_abs,linear.vectorScaling(Camera.transform.tMatrix.yVector,500*dt)))
  end

  if love.keyboard.isDown("right") == true then
    Camera.transform:changevar("tMatrix",Camera.transform.tMatrix:getRotated(5*dt))
  elseif love.keyboard.isDown("left") == true then
    Camera.transform:changevar("tMatrix",Camera.transform.tMatrix:getRotated(-5*dt))
  end 
  
  
end
--[[
function love.wheelmoved(dx,dy)
  print(dy)
  Camera.transform:changevar("tMatrix",Camera.transform.tMatrix:getEvenlyscaled(1.0+dy*0.01))
end
]]
function love.draw()
  Renderer.showFrame()
end
