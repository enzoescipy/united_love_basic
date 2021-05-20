--
-- gameobj
-- 
-- where gameobj are decleared.
--
local Object = require "packages.classic"
local queue = require "packages.queue"
local clone = require "packages.clone"
local ID = require "packages.id"

require "component"
-- first, make class for all gameobjects.
GameObject = Object:extend()

-- gbjlists are like unity's Hierarchy. it is pool of gbj in use.
-- namelist and its inv are exists only for searching gbj.
Dictionary = {}
Dictionary.list = {}
Dictionary.namelist = {}
Dictionary.namelistInv = {}


-- create, search, destroy gameobj
function GameObject:new(name, ...)
  -- reject if there is already same name in gbjs.
  if Dictionary.namelistInv[name] ~= nil then
    print("there is already same gameobject name in Hierarchy.")
    donotusecauseitisforerrorrasing[1]=0
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
    
  for i,v in ipairs({...}) do
    self:attach(v)
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
    print("there is already same gameobject name in Hierarchy.")
    donotusecauseitisforerrorrasing[1]=0
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

-- attach and detach components.
function GameObject:attach(componentName)
  if componentName == "T" then
    self.transform = Transform()
  elseif componentName == "G" then
    self.graphics = Graphics()
  elseif componentName == "F" then
    self.folder = Folder()
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