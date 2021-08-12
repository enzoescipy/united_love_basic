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


BananaCam = GameObject:find("BananaCam")
Camera = GameObject:find("Camera")


function love.load()
  Graphics.setWindowSize(1024,640)
end

function love.update(dt)

  if love.keyboard.isDown("up") then
    BananaCam.transform:changevar("y", BananaCam.transform.y + 100*dt)
  elseif love.keyboard.isDown("down") then
    BananaCam.transform:changevar("y", BananaCam.transform.y - 100*dt)
  elseif love.keyboard.isDown("right") then
    BananaCam.transform:changevar("r", BananaCam.transform.r - dt)
  elseif love.keyboard.isDown("left") then
    BananaCam.transform:changevar("r", BananaCam.transform.r + dt)
  end
  

end

function love.draw()
  Renderer.showFrame()
end

print("--test")
print("--test")
