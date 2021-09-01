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
  --Banana.transform:changevar("tMatrix",Banana.transform.tMatrix:getRotated(dt))
  --Banana.transform:changevar("y", Banana.transform.y + dt*100)
end

function love.draw()
  Renderer.showFrame()
end

--[[
print("*")
local testgbj = GameObject("testgbj","T")
for i = 1,10 do
  print(testgbj.transform.tMatrix:takeRotation())
  print(testgbj.transform.tMatrix.xVector[1],testgbj.transform.tMatrix.xVector[2])
  testgbj.transform.tMatrix = testgbj.transform.tMatrix:getRotated(0.01)
end
print("*")
]]