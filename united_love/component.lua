--
-- component
-- 
-- where all kinds of component for gameobject from.
-- its method name will like Transform => gameobj.transform
--

local Object = require "united_love.packages.classic"
local queue = require "united_love.packages.queue"
local clone = require "united_love.packages.clone"
local ID = require "united_love.packages.id"


-- Transform


Transform = Object:extend()
tID = ID("transform")
function Transform:new()
  self.id = tID:makeid()
  self.isAlive = true
  self.type = "Transform"

  self.x = 0.0
  self.y = 0.0

  self.reactlist = {}
  self.aimlist = {}
  self.aimednameInv = {}
  self.aimednamecalled = {}

  self.varnames = {"x", "y"}
  self.varnamesInv = {}
  self.varnamesInv["x"] = 1
  self.varnamesInv["y"] = 2
  self.varnamesRecursion = {0,0}
end

function Transform:inactivate()
  if self.isAlive == false then
    return
  end
  self.isAlive = false
end

function Transform:reactivate()
  self.isAlive = true
end

function Transform:newvar(name)
  if self.isAlive == false then
    return
  end
  self[name] = 0.0
  table.insert(self.varnames, name)
  self.varnamesInv[name] = #self.varnames

  table.insert(self.varnamesRecursion, 0)
end

function Transform:delvar(name)
  if self.isAlive == false then
    return
  end
  local index = self.varnamesInv[name]
  table.remove(self.varnames, index)

  table.remove(self.varnamesRecursion, index)

  for i,v in ipairs(self.varnames) do
    self.varnamesInv[v] = i
  end
end

function Transform:aim(transform)
  if self.isAlive == false then
    return
  end
  local index = self.aimednameInv[transform.id]
  if transform.type == "Transform"  then
    if  index == nil then
      table.insert(self.aimlist, transform)
      self.aimednameInv[transform.id] = #self.aimednameInv
      self.aimednamecalled[transform.id] = 1
    else
      self.aimednamecalled[transform.id] = self.aimednamecalled[transform.id] + 1
    end
  else
    print("type error. in  transform:aim")
    donotusecauseitisforerrorrasing[1]=0
  end
end

function Transform:notaim(transform)
  if self.isAlive == false then
    return
  end
  local index = self.aimednameInv[transform.id]
  if transform.type == "Transform" and index ~= nil then
    self.aimednamecalled[transform.id] = self.aimednamecalled[transform.id] - 1
    local life = self.aimednamecalled[transform.id]
    if life >= 1 then
      return
    else
      self.aimednamecalled[transform.id] = nil
      table.remove(self.aimlist, index)
      self.aimednameInv = {}
      for i,transform in ipairs(self.aimlist) do
        self.aimednameInv[transform.id] = i
      end
    end
  else
    print("type error or existance error. in  transform:notaim")
    donotusecauseitisforerrorrasing[1]=0
  end
end

function Transform:willreact(transform, mastername, targetname, willfunction)
  if self.isAlive == false then
    return
  end
  local idseed = transform.id..":"..mastername
  if self.reactlist[idseed] == nil then
    self.reactlist[idseed] = {}
  end
  table.insert(self.reactlist[idseed],{targetname, willfunction})
  self.reactlist[idseed][targetname] = #self.reactlist[idseed]
end

function Transform:notwillreact(transform, mastername, targetname)
  if self.isAlive == false then
    return
  end
  local idseed = transform.id..":"..mastername
  local tab = self.reactlist[idseed]
  if tab == nil then
    print("warning! there is no react.")
    return
  end
  local varnameindex = tab[targetname]
  table.remove(self.reactlist[idseed], varnameindex)
  for i,v in ipairs(self.reactlist[idseed]) do
    self.reactlist[idseed][v[1]] = i
  end
  if #self.reactlist[idseed] == 0  then
    self.reactlist[idseed] = nil
  end
end

function Transform:changevar(varname, value)
  if self.isAlive == false then
    return
  end
  local oldvar = self[varname]
  local newvar = value
  self[varname] = value

  for i = 1, #self.aimlist do
    if self.aimlist[i]:call(self, varname, oldvar, newvar) == "exploded" then
      self:notaim(self.aimlist[i])
    end
  end
end

function Transform:call(transform, varname, oldvalue, newvalue)
  if self.isAlive == false then
    return
  end
  local idseed = transform.id .. ":" .. varname
  local tab = self.reactlist[idseed]
  if tab == nil then
    return
  end
  for i,varpair in ipairs(tab) do
    local varname = varpair[1]
    local wilfunc = varpair[2]
    local targetvalue = self[varname]
    local result = wilfunc(oldvalue, newvalue, targetvalue)
    self:changevar(varname, result)
  end
end

function Transform:recursionTestChange(varname)
  if self.isAlive == false then
    return
  end

  local index = self.varnamesInv[varname]
  self.varnamesRecursion[index] = self.varnamesRecursion[index] + 1

  if self.varnamesRecursion[index] >= 2 then
    self.varnamesRecursion[index] = 0
    return true
  end

  for j = 1, #self.aimlist do
    if self.aimlist[j]:recursionTestCall(self, varname) == true then
      return true
    end
  end

  self.varnamesRecursion[index] = 0
  return false
end

function Transform:recursionTestCall(transform, varname)
  if self.isAlive == false then
    return
  end
  
  local idseed = transform.id .. ":" .. varname
  local tab = self.reactlist[idseed]
  if tab == nil then
    return
  end
  for i,varpair in ipairs(tab) do
    local varname = varpair[1]
    if self:recursionTestChange(varname) == true then
      return true
    end
  end
end

function Transform:explode()
  
  for i = 1, #self.aimlist do
    for j = i, #self.varnames do
      self.aimlist[i]:notwillreact(self, self.varnames[j])
    end
  end

  for i,v in pairs(self) do
    self[i] = false
  end

  function self:call(transform, varname, oldvalue, newvalue)
    return "exploded"
  end

  self.isAlive = false
end

--Transform.presetfunc
Transform.presetfunc = {}
function Transform.presetfunc.equal(oldvalue, newvalue, targetvalue)
  return newvalue
end

function Transform.presetfunc.follow(oldvalue, newvalue, targetvalue)
  return targetvalue - oldvalue + newvalue
end 
--

--Transform class method
function Transform:relation(transform1, var1, transform2, var2, willfunction)--transform1.var1 to transform2.var2, relation is willfunciton(oldvalue, newvalue, targetvalue)
  transform1:aim(transform2)
  transform2:willreact(transform1, var1, var2, willfunction)
  if transform1:recursionTestChange(var1) == true then
    print("recursion detected. Transform:relation rejected.")
    transform1:notaim(transform2)
    transform2:notwillreact(transform1, var1, var2)
  end
end
--

-- Graphics
Graphics = Object:extend()

function Graphics:new()
  self.drawable = "invaild_value"
  self.xsize = 0.0
  self.ysize = 0.0
  self.isAlive = true
  self.type = "Graphics"
end

function Graphics:newjpgImage(imgdirectory)
  if self.isAlive == false then
    return
  end
  self.drawable = love.graphics.newImage(imgdirectory)
end

function Graphics:inactivate()
  if self.isAlive == false then
    return
  end
  self.isAlive = false
end

function Graphics:reactivate()
  self.isAlive = true
end

function Graphics:explode()
  for i,v in pairs(self) do
    self[i] = false
  end

  self.isAlive = false
end
--

-- Folder
Folder = Object:extend()
fID = ID("folder")

function Folder:new()
  self.id = fID:makeid()
  self.type = "Folder"

  self.gbjstore = {}
  self.gbjNamestore = {}
  self.gbjNamestoreInv = {}

  self.owner = nil

  self.isrecursionTestActivated = 0
end

function Folder:include(gbj) -- 
  local name = gbj.name
  table.insert(self.gbjstore, gbj)
  table.insert(self.gbjNamestore, name)
  self.gbjNamestoreInv[name] = #self.gbjNamestore
  if gbj.folder ~= nil then
    gbj.folder.owner = self
  end
end

function Folder:exclude(gbj)
  local name = gbj.name
  if gbj.folder ~= nil then
    gbj.folder.owner = nil
  end
  local index = self.gbjNamestoreInv[name]
  self.gbjNamestoreInv[name] = nil
  table.remove(self.gbjNamestore, index)
  table.remove(self.gbjstore, index)
  --refresh gbjnamestoreINV
  self.gbjNamestoreInv = {}
  for i,v in ipairs(self.gbjNamestore) do
    self.gbjNamestoreInv[v] = i
  end
end

function Folder:recursionTest()
  self.isrecursionTestActivated = self.isrecursionTestActivated + 1
  if self.isrecursionTestActivated >= 2 then
    self.isrecursionTestActivated = 0
    return true
  end
  for i,gbj in self.gbjstore do
    if gbj.folder ~= nil then
      local testbool = gbj.folder:recursionTest()
      if testbool == true then
        return true
      end
    end
  end
  if self.isrecursionTestActivated == 1 then
    return false
  end

  return nil
end

function Folder:explode()
  for i,v in pairs(self) do
    self[i] = false
  end

  self.isAlive = false
end