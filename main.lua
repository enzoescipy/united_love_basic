local parser = require "united_love.packages.parser"
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
  Banana.transform:changevar("x", Banana.transform.x + 100 * dt)
  --Apple.transform:changevar("x", Apple.transform.x + 100 * dt)

  
  
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