--
-- component
-- 
-- require order = 2
-- where all kinds of component for gameobject from.
-- its method name will like Transform => gameobj.transform
--

local Object = require "united_love.packages.classic"
local queue = require "united_love.packages.queue"
local clone = require "united_love.packages.clone"
local ID = require "united_love.packages.id"
local linear = require "united_love.packages.linear"

require "united_love.renderer"

-- Transform
-- #region
Transform = Object:extend()
function Transform:new(ownergbj)
  self.id = ownergbj.name..".".."transform"
  self.isAlive = true
  self.type = "Transform"

  -- x y r xs ys are graphical variables connected to Graphical. component. DO NOT DELET THAT.
  self.x = 0.0 -- x pos
  self.y = 0.0 -- y pos
  self.r = 0.0 -- rotation radian
  self.xs = 1.0 -- x scale
  self.ys = 1.0 -- y scale
  self.graphical = nil

  self.reactlist = {}
  self.aimlist = {}
  self.aimednameInv = {}
  self.aimednamecalled = {}

  self.varnames = {"x", "y","r","xs","ys"}
  self.varnamesInv = {}
  for i,v in ipairs(self.varnames) do
    self.varnamesInv[v] = i
  end
  self.varnamesRecursion = {0,0,0,0,0,0,0}
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

  -- special changes for x and y to sending then Graphical Renderer.
  if self.graphical ~= nil then
    if varname == "x" then
      Renderer.compensate(value,nil,nil,nil,nil,nil,nil, self.graphical.id)
    elseif varname == "y" then
      Renderer.compensate(nil,value,nil,nil,nil,nil,nil, self.graphical.id)
    elseif varname == "r" then
      Renderer.compensate(nil,nil,value, nil,nil,nil,nil, self.graphical.id)
    elseif varname == "xs" then
      Renderer.compensate(nil,nil,nil, value,nil,nil,nil, self.graphical.id)
    elseif varname == "ys" then
      Renderer.compensate(nil,nil,nil, nil,value,nil,nil, self.graphical.id)
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
Transform.presetfunc = {"x", "y","r","xs","ys"}
function Transform.presetfunc.equal(oldvalue, newvalue, targetvalue)
  return newvalue
end

function Transform.presetfunc.follow(oldvalue, newvalue, targetvalue)
  return targetvalue - oldvalue + newvalue
end 

--

--Transform class method
Transform.basicVarNames = {"x", "y","r","xs","ys"}

function Transform.relation(transform1, var1, transform2, var2, willfunction)--transform1.var1 to transform2.var2, relation is willfunciton(oldvalue, newvalue, targetvalue)
  transform1:aim(transform2)
  transform2:willreact(transform1, var1, var2, willfunction)
  if transform1:recursionTestChange(var1) == true then
    print("recursion detected. Transform:relation rejected.")
    transform1:notaim(transform2)
    transform2:notwillreact(transform1, var1, var2)
  end
end

function Transform.doRelationAll(master, slaves, relationfunc) --master to slaves relation. slaves = {skave1gbj, slave2gbj, ...}
  for i,gbj in ipairs(slaves) do
    for i,name in ipairs(Transform.basicVarNames)do
      Transform.relation(master.transform, name, gbj.transform, name, relationfunc)
    end
  end
end

function Transform.refactor(transform1, var1,transform2, var2,transform3, var3, XtoYrelationfunc,YtoZrelationfunc) 
  -- relation t1.v1 to t2.v2 will same but relation t2.v2 to t3.v3 will dosen't make t3 transform's aimlist. but just ignoring changevar system and change it directly. 
  -- e.g) if you want to set relation like AA.x -> BB.x -> AA.x but not want to make recursion,
  -- use like: Transform.refactor(AA.transform, "x", BB.transform, "x",AA.transform, "x", AAtoBBrelationfunc, BBtoAArelationfunc) 
  -- then it will really do change BB.x when AA.x changes(by AAtoBBrelationfunc), and also change AA.x again immediately(by BBtoAArelationfunc),
  -- without change BB.x again by recursion.

  -- WARNING : last target (t3.v3 or AA.x) MUST NOT HAVE "ANY" other relationship. because this func will change last target and just ignoring transform's changevar system.
  local function refactoror(oldvalue, newvalue, targetvalue)
    local newvalue_y = XtoYrelationfunc(oldvalue, newvalue, targetvalue)
    local oldvalue_y = targetvalue
    transform3[var3] = YtoZrelationfunc(oldvalue_y, newvalue_y, transform3[var3])
    return newvalue_y
  end
  Transform.relation(transform1, var1, transform2, var2, refactoror)
end

function Transform.unitylikeMastertoSlave(master, slaves) --master to slave relations. make relation of transformation like unity's parent and children.
  for i,slav in ipairs(slaves) do
    Transform.relation(master.transform, "x", slav.transform, "x", Transform.presetfunc.follow)
    Transform.relation(master.transform, "y", slav.transform, "y", Transform.presetfunc.follow)
    slav.transform:newvar("xlocal")
    slav.transform:changevar("xlocal",0.0)
    slav.transform:newvar("ylocal")
    slav.transform:changevar("ylocal",0.0)
  end
end
-- #endregion

-- Graphics
-- #region
Graphics = Object:extend()
function Graphics:new(ownergbj, transform)
  self.drawable = "invaild_value"
  self.width = 0.0
  self.height = 0.0
  self.isAlive = true
  self.type = "Graphics"
  self.id = ownergbj.name..".".."graphics"
  if transform ~= nil then
    transform.graphical = self
    Renderer.createpivot(self.id)
    Renderer.compensate(transform.x, transform.y,transform.r,transform.xs,transform.ys, nil, nil, self.id)
  end
end

function Graphics:newjpgImage(imgdirectory)
  if self.isAlive == false then
    return
  end
  self.drawable = love.graphics.newImage(imgdirectory)
  self.width =  self.drawable:getWidth()
  self.height = self.drawable:getHeight()
  Renderer.compensate(nil, nil,nil,nil,nil, self.width, self.height, self.id)
end

function Graphics:newText(text,sizepx)
  if self.isAlive == false then
    return
  end
  self.drawable = love.graphics.newText(love.graphics.newFont(sizepx), text)
  self.width =  self.drawable:getWidth()
  self.height = self.drawable:getHeight()
  Renderer.compensate(nil, nil,nil,nil,nil, self.width, self.height, self.id)
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
-- #endregion

-- Folder
-- #region
Folder = Object:extend()
function Folder:new(ownergbj)
  self.id = ownergbj.name..".".."folder"
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
-- #endregion