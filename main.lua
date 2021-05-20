--
-- gameobj
-- 
-- where gameobj are decleared.
--

Main = require "gameobjList"

--main thread
-- :warning! Cashing the component like "trans = gameobj.transform" or "obj = gameobj" to referencing
-- component of some object easily and NOT DELETING cashed variables like "trans = nil" can
-- cause MEMORY LEAK. DO delete cashed vars after using it.
-- if you wanna destroy the cashed gameobject, please do it like "<Name> = nill"



Banana = GameObject:find("Banana")
Apple = GameObject:find("Apple")

function love.load()

end

function love.update(dt)
  Banana.transform:changevar("x", Banana.transform.x + 10 * dt)
  Apple.transform:changevar("x", Apple.transform.x + 10 * dt)
  
end

function love.draw()
  for i,gbj in ipairs(Dictionary.list) do
    if gbj.transform ~= nil and gbj.graphics ~= nil then
      love.graphics.draw(gbj.graphics.drawable, gbj.transform.x, gbj.transform.y)
    end
  end
end
