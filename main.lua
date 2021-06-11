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
  Banana.transform:changevar("x", Banana.transform.x + 1000 * dt)
  --Apple.transform:changevar("x", Apple.transform.x + 100 * dt)

  
  
end

function love.draw()
  for i,gbj in ipairs(Dictionary.list) do
    if gbj.transform ~= nil and gbj.graphics ~= nil then
      love.graphics.draw(gbj.graphics.drawable, gbj.transform.x, gbj.transform.y)
    end
  end

  local function idDo(id)
    local idbox = Graphics.renderer.renderTarget_pivotdata[id]
    local x = idbox[1]
    local y = idbox[2]
    love.graphics.rectangle("fill", x,y,10,10)
  end
  Graphics.renderer.calculateALL()
  Graphics.renderer.renderRectpivotDo(0,1024,0,640,idDo)
end



