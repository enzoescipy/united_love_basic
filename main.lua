local linear = require "united_love.packages.linear"
--
-- gameobj
-- 
-- where gameobj are decleared.
--

Main = require "test_gameobjList"

--main thread
-- :warning! Cashing the component like "trans = gameobj.transform" or "obj = gameobj" to referencing
-- component of some object easily and NOT DELETING cashed variables like "trans = nil" can
-- cause MEMORY LEAK. DO delete cashed vars after using it.
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nill"






Banana = GameObject:find("Banana")
Apple = GameObject:find("Apple")

function love.load()
  love.window.setMode(1024, 640)
end

function love.update(dt)
  --local banana_pos = {Banana.transform.x, Banana.transform.y}
  --banana_pos = linear.rotate({0,0},banana_pos,dt)
  --Banana.transform:changevar("x", banana_pos[1])
  --Banana.transform:changevar("y", banana_pos[2])

  Banana.transform:changevar("x", Banana.transform.x + dt*100)

  --Apple.transform:changevar("x", Apple.transform.x + 100 * dt)
  --Banana.transform:changevar("x", Banana.transform.x + 10*dt)

  
  
end

function love.draw()

  Renderer_Main:refresh()
  Renderer_Main:drawSpritesPivot()
  Renderer_Main:drawALL()
  local mainCanvas = Renderer_Main:getcanvas()
  love.graphics.push()
    love.graphics.draw(mainCanvas)
  love.graphics.pop()
end

print("--test")
print("--test")