--
-- gameobj
-- 
-- require order = 3
-- where gameobj are decleared.
--
local Object = require "united_love.packages.classic"
local clone = require "united_love.packages.clone"
local parser = require "united_love.packages.parser"
local linear = require "united_love.packages.linear"

require "united_love.component"
-- first, make class for all gameobjects.
GameObject = Object:extend()

-- gbjlists are like unity's Hierarchy. it is pool of gbj in use.
-- namelist and its inv are exists only for searching gbj.
Dictionary = {}
Dictionary.list = {}
Dictionary.namelist = {}
Dictionary.namelistInv = {}


-- create, search, destroy gameobj
function GameObject:new(name, ...) --please type "T" then type "G" because graphic component need transform component first.
  -- reject if there is already same name in gbjs.
  if Dictionary.namelistInv[name] ~= nil then
    print("there is already same gameobject name in Hierarchy. order rejected.")
  end
  -- declare instance attribute
  self.name = name
  self.type = "GameObject"
  self.isAlive = true
    
  -- write list of all possible component gameobj can get
  self.transform = nil --"T"
  self.graphics = nil -- "G"
  self.folder = nil -- "F"
  --
  local complist = {...}
  for i = 1,#complist do
    self:attach(complist[i])
  end
    
  -- fill the gbjlist, gbjnamelist, and its inv.
  table.insert(Dictionary.list, self)
  local myindex = #Dictionary.list
  table.insert(Dictionary.namelist, self.name)
  Dictionary.namelistInv[self.name] = myindex

end

function GameObject:copynew(newname)
  -- reject if there is already same name in gbjs.
  if Dictionary.namelistInv[newname] ~= nil then
    print("there is already same gameobject name in Hierarchy. order rejected.")
  end

  local newgbj = clone.clone(self)
  newgbj.name = newname

  table.insert(Dictionary.list, newgbj)
  local myindex = #Dictionary.list
  table.insert(Dictionary.namelist, newgbj.name)
  Dictionary.namelistInv[newgbj.name] = myindex

  return newgbj
end

function GameObject:find(name)
  local index = Dictionary.namelistInv[name]
  if  index == nil then
    return nil
  else
    return Dictionary.list[index]
  end
end

function GameObject:nameparse(namestring)
  return parser.split(namestring,"%.")[1]
end

function GameObject:explode()
  -- Hierarchy remove
  local index = Dictionary.namelistInv[self.name]
  table.remove(Dictionary.list, index)
  table.remove(Dictionary.namelist, index)
  -- refresh namelistInv
  Dictionary.namelistInv = {}
  for i,v in ipairs(Dictionary.namelist) do
    Dictionary.namelistInv[v] = i
  end
  -- kill components and itself
  self.transform:explode()
  self.graphics:explode()
  self.folder:explode()

  for i,v in pairs(self) do
    self[i] = false
  end

  self.isAlive = false
end

function GameObject:inactivate()
  self.isAlive = false
  if self.transform ~= nil then
    self.transform.isAlive = false
  end
  if self.graphics ~= nil then
    self.graphics.isAlive = false
  end
  if self.folder == nil then
    return
  end
  for i = 1, #self.folder.gbjstore do
    self.folder.gbjstore[i]:inactivate()
  end
end

function GameObject:reactivate()
  self.isAlive = true
  if self.transform ~= nil then
    self.transform.isAlive = true
  end
  if self.graphics ~= nil then
    self.graphics.isAlive = true
  end
  if self.folder == nil then
    return
  end
  for i = 1, #self.folder.gbjstore do
    self.folder.gbjstore[i]:reactivate()
  end
end

-- attach and detach components.
function GameObject:attach(componentName)
  if componentName == "T" then
    self.transform = Transform(self)
  elseif componentName == "G" then
    if self.transform ~= nil then
      self.graphics = Graphics(self,self.transform)
    else
      print("Graphic component MUST NEED Transform component FIRST. order rejected.")
    end
  elseif componentName == "F" then
    self.folder = Folder(self)
  end
end

function GameObject:detach(componentName)
  if componentName == "T" then
    self.transform = nil
  elseif componentName == "G" then
    self.graphics = nil
  elseif componentName == "F" then
    self.folder = nil
  end
end
--#region
-- easymethod.

--  self.folder easy-method.
function GameObject:fInclude(gbj)
  if self.folder == nil then
    print("there is no folder.")
    return -1
  end

  self.folder:include(gbj)
end
function GameObject:fExclude(gbj)
  if self.folder == nil then
    print("there is no folder.")
    return -1
  end

  self.folder:exclude(gbj)
end
function GameObject:fShow()
  -- DO NOT CHANGE result. if you want to change it, raise gameobj:copy() first .
  if self.folder == nil then
    print("there is no folder.")
    return -1
  end

  return self.folder.gbjstore
end

-- self.transform easy-method.

function GameObject:children_unite()
  if self.folder == nil then
    print("there is no folder.")
    return -1
  elseif self.transform == nil then
    print("there is no transform.")
    return -1
  elseif #self.folder.gbjstore == 0 then
    print("there is no children.")
    return -1
  end

  Transform.unitylikeMastertoSlave(self, self.folder.gbjstore)
end

function GameObject:x(...) -- no value == show, 1 value == changevar.
  if self.transform == nil then
    print("there is no transform.")
    return -1
  end
  local input = {...}
  local position 
  local poisition_name

  if self.transform.master == nil then
    position = self.transform.pos_abs
    poisition_name = "pos_abs"
  else
    position = self.transform.pos
    poisition_name = "pos"
  end
  if #input >= 2 then
    print("too many arguments.")
    return -1
  elseif #input == 1 then
    local value = input[1]
    self.transform:changevar(poisition_name,{value,position[2]})
  elseif #input == 0 then
    return position[1]
  end
end

function GameObject:y(...) -- no value == show, 1 value == changevar.
  if self.transform == nil then
    print("there is no transform.")
    return -1
  end
  local input = {...}
  local position 
  local poisition_name

  if self.transform.master == nil then
    position = self.transform.pos_abs
    poisition_name = "pos_abs"
  else
    position = self.transform.pos
    poisition_name = "pos"
  end
  if #input >= 2 then
    print("too many arguments.")
    return -1
  elseif #input == 1 then
    local value = input[1]
    self.transform:changevar(poisition_name,{position[1],value})
  elseif #input == 0 then
    return position[2]
  end
end

function GameObject:pos(...) -- no value == show, 1 value == changevar.
  if self.transform == nil then
    print("there is no transform.")
    return -1
  end
  local input = {...}
  local position 
  local poisition_name

  if self.transform.master == nil then
    position = self.transform.pos_abs
    poisition_name = "pos_abs"
  else
    position = self.transform.pos
    poisition_name = "pos"
  end
  if #input >= 2 then
    print("too many arguments.")
    return -1
  elseif #input == 1 then
    local value = input[1]
    self.transform:changevar(poisition_name,value)
  elseif #input == 0 then
    return clone.cloneD1(position)
  end
end

function GameObject:posAdd(deltapos) -- add deltapos to current position.
  if self.transform == nil then
    print("there is no transform.")
    return -1
  end
  local position 
  local poisition_name

  if self.transform.master == nil then
    position = self.transform.pos_abs
    poisition_name = "pos_abs"
  else
    position = self.transform.pos
    poisition_name = "pos"
  end
  self.transform:changevar(poisition_name,linear.vectorAdd(position, deltapos))
end

function GameObject:tmat(...) -- no value == show, 1 value == changevar.
  if self.transform == nil then
    print("there is no transform.")
    return -1
  end
  local input = {...}
  local tmatrix = self.transform.tMatrix
  if #input >= 2 then
    print("too many arguments.")
    return -1
  elseif #input == 1 then
    local value = input[1]
    self.transform:changevar("tMatrix",value)
  elseif #input == 0 then
    return tmatrix:copy()
  end
end

--#endregion
