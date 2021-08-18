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
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nill"


Banana = GameObject:find("Banana")
Camera = GameObject:find("Camera")

--[[

function love.load()
  Graphics.setWindowSize(1024,640)
end

function love.update(dt)

  if love.keyboard.isDown("up") then
    Banana.transform:changevar("y", Banana.transform.y + 100*dt)
  elseif love.keyboard.isDown("down") then
    Banana.transform:changevar("y", Banana.transform.y - 100*dt)
  elseif love.keyboard.isDown("right") then
    Banana.transform:changevar("r", Banana.transform.r - dt)
  elseif love.keyboard.isDown("left") then
    Banana.transform:changevar("r", Banana.transform.r + dt)
  end
  

end

function love.draw()
  Renderer.showFrame()
end
]]

print("--test")
print("--test")

a = GameObject("a","T")
a.transform:changevar("r",1)