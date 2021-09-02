local parser = require "united_love.packages.parser"

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


require "united_love.united_love" 


-- if your united_love module folder is in the /package folder, please like this;
-- package.path = package.path .. ";packages/?.lua
-- require "united_love.united_love"

-- For here, declare GameObjects, which need to be decleared before game start.

-- setting section ::



-- end ::


local Camera = GameObject("Camera","T","F")
local Window_camera = GameObject("Window_camera","T","G")
Renderer_cam1 = Renderer()
Renderer_cam1:equip(Camera,Window_camera, 800,600)
local tempname = "Road"
local Road_pic = GameObject(tempname.."_pic","T","G")
Road_pic.graphics:newjpgImage("exp_sprites/road.png")
local Road_text = GameObject(tempname.."_text","T","G")
local Road = GameObject(tempname, "T", "F")
Road.folder:include(Road_pic)
Transform.unitylikeMastertoSlave(Road, Road.folder.gbjstore)
Renderer_cam1:recept_automatically(Road)
local tempname = "Banana"
local Banana_pic = GameObject(tempname.."_pic","T","G")
Banana_pic.graphics:newjpgImage("exp_sprites/banana.jpg")
local Banana_text = GameObject(tempname.."_text","T","G")
Banana_text.graphics:newText("Banana!", 20)
local Banana = GameObject(tempname, "T", "F")
Banana.folder:include(Banana_pic)
Banana.folder:include(Banana_text)
Transform.unitylikeMastertoSlave(Banana, Banana.folder.gbjstore)
Banana_text.transform:changevar("pos",{0,-100})
Renderer_cam1:recept_automatically(Banana)

Camera.folder:include(Banana)
Transform.unitylikeMastertoSlave(Camera, Camera.folder.gbjstore)