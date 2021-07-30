local linear = require "united_love.packages.linear"
--
-- gameobj
-- 
-- where gameobj are decleared.
--

Main = require "test_gameobjList"

--main thread
-- :warning! Cashing the component like "trans = gameobj.transform" or "j" to referencing
-- component obj = gameobof some object easily and NOT DELETING cashed variables like "trans = nil" can
-- cause MEMORY LEAK. DO delete cashed vars after using it.
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nill"


Banana = GameObject:find("Banana")
Apple = GameObject:find("Apple")
Cam1 = GameObject:find("Camera")

function love.load()
  Graphics.setWindowSize(1024,640)
end

function love.update(dt)
  -- Banana.transform:changevar("r", Banana.transform.r + dt)
  -- Banana.transform:changevar("ys", Banana.transform.ys + dt)
  Banana.transform:changevar("xs", Banana.transform.xs + dt)
  Cam1.transform:changevar("ys", Cam1.transform.ys + dt)
end

function love.draw()
  Renderer.showFrame()
end

print("--test")
print("--test")
