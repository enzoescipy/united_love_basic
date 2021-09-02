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
    Camera:posAdd(linear.vectorScaling(Camera:tmat().yVector,-500*dt))
  elseif love.keyboard.isDown("down") == true then
    Camera:posAdd(linear.vectorScaling(Camera:tmat().yVector,500*dt))
  end

  if love.keyboard.isDown("right") == true then
    Camera:tmat(Camera:tmat():getRotated(5*dt))
  elseif love.keyboard.isDown("left") == true then
    Camera:tmat(Camera:tmat():getRotated(-5*dt))
  end 
end
function love.draw()
  Renderer.showFrame()
end
