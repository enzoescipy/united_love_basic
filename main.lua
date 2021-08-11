local linear = require "united_love.packages.linear"
--
-- gameobj
-- 
-- where gameobj are decleared.
--

Main = require "test_gameobjList"

-- :warning! Cashing 
--main threadthe component like "trans = gameobj.transform" or "j" to referencing
-- component obj = gameobof some object easily and NOT DELETING cashed variables like "trans = nil" can
-- cause MEMORY LEAK. DO delete cashed vars after using it.
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nill"


Banana = GameObject:find("Banana")
--Apple = GameObject:find("Apple")
Cam1 = GameObject:find("Camera")

function love.load()
  Graphics.setWindowSize(1024,640)
end

function love.update(dt)
  --[[
  if love.keyboard.isDown("right") then
    Banana.transform:changevar("r",Banana.transform.r - 0.001)
  elseif love.keyboard.isDown("left") then
    Banana.transform:changevar("r",Banana.transform.r + 0.001)
  end
  ]]
  if love.keyboard.isDown("right") then
    Cam1.transform:changevar("r", Cam1.transform.r - 0.01)
  elseif love.keyboard.isDown("left") then
    Cam1.transform:changevar("r", Cam1.transform.r + 0.01)
  end
  

end

function love.draw()
  Renderer.showFrame()
end

print("--test")
print("--test")
