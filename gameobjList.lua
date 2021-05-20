-- if you want to create new game object, there is two ways of that.
--
-- first method is, STATIC METHOD. just write <Name> = GameObject(<Name>) same as making new instance.
-- this way, you can use GameObject by directly using <Name>.
-- however, you can't create GameObject dynamically.
--
-- Second method is, DYNAMIC METHOD don't assign instance and just writs GameObject(<Name>) alone.
-- this way, you can't use GameObject directly by using its variable name, cause it dosen't has one. 
-- rather than call it by its variable name, you should use GameObject:find(<Name>).
-- but, you can create GameObject dynamically, maybe by use for loop.
--
-- Just remember... if you did first method, PLEASE REMOVE variable like "<Name>=nill"  or it will DISRUPT the GamObject.destroy.
-- and it may cause serious memory overflow problem.

require "gameobj"

-- For here, declare GameObjects, which need to be decleared before game start.

local Banana_pic = GameObject("Banana_pic","T","G")
Banana_pic.graphics:newjpgImage("exp_sprites/banana.jpg")
Banana_pic.transform.x = 100
Banana_pic.transform.y = 100

local Banana_text = GameObject("Banana_text","T","G")
Banana_text.graphics.drawable = love.graphics.newText(love.graphics.getFont(), "Banana!")
Banana_text.transform.x = 100
Banana_text.transform.y = 75

local Apple_pic = GameObject("Apple_pic","T","G")
Apple_pic.graphics:newjpgImage("exp_sprites/apple.jpg")
Apple_pic.transform.x = 500
Apple_pic.transform.y = 500

local Apple_text = GameObject("Apple_text","T","G")
Apple_text.graphics.drawable = love.graphics.newText(love.graphics.getFont(), "Apple!")
Apple_text.transform.x = 500
Apple_text.transform.y = 475

local Banana = GameObject("Banana", "T", "F")
Banana.transform.x = 100
Banana.transform.y = 100
Banana.folder:include(Banana_pic)
Banana.folder:include(Banana_text)
for i,gbj in ipairs(Banana.folder.gbjstore) do
  Transform:relation(Banana.transform, "x", gbj.transform, "x", Transform.presetfunc.follow)
  Transform:relation(Banana.transform, "y", gbj.transform, "y", Transform.presetfunc.follow)
end

local Apple = GameObject("Apple", "T", "F")
Apple.transform.x = 100
Apple.transform.y = 100
Apple.folder:include(Apple_pic)
Apple.folder:include(Apple_text)
for i,gbj in ipairs(Apple.folder.gbjstore) do
  Transform:relation(Apple.transform, "x", gbj.transform, "x", Transform.presetfunc.follow)
  Transform:relation(Apple.transform, "y", gbj.transform, "y", Transform.presetfunc.follow)
end

local MAIN = GameObject("HIERARCHY", "F")
MAIN.folder:include(Apple)
MAIN.folder:include(Banana)
return MAIN

--