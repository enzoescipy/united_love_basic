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
  Banana.transform:changevar("r", Banana.transform.r + dt)
  Banana.transform:changevar("ys", Banana.transform.ys + dt)
  Banana.transform:changevar("xs", Banana.transform.ys + dt)
  
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
--[[

a = GameObject("a", "T")
b = GameObject("b", "T")
c = GameObject("c", "T")
s = GameObject("s", "T")

a.transform:changevar("x", 1)
b.transform:changevar("x", 2)
s.transform:changevar("x", 10)
b.transform:changevar("y", 20)

local function follow2(ownerTransform,ownerName,targetTransform,targetName,owner_oldvalue)
  local owner_newvalue = ownerTransform[ownerName]
  local owner_delta = owner_newvalue - owner_oldvalue
  local target_x = targetTransform.x + owner_delta
  local target_y = targetTransform.y + owner_delta
  targetTransform:changevar("x", target_x)
  targetTransform:changevar("y", target_y)
end

--Transform.relation(a.transform, "x", b.transform, "x", Transform.presetfunc.follow)
Transform.relation(s.transform, "x", a.transform, "x", Transform.presetfunc.follow)
Transform.relation(a.transform, "x", b.transform, "any", follow2)
Transform.relation(b.transform, "x", a.transform, "x", Transform.presetfunc.follow)


result = s.transform:changevar("x", 11)

print(s.transform.x, a.transform.x, b.transform.x, b.transform.y)
print(result)
]]