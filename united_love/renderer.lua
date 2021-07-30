local linear = require "united_love.packages.linear"
local clone = require "united_love.packages.clone"
--
-- renderer
--
-- require order = 1
-- 
-- where .graphics component's drawables are render.
--
local Object = require "united_love.packages.classic"

--
--

-- Renderer
Renderer = Object:extend()
Renderer.renderTarget_pivotmaker = {}
Renderer.renderers_list = {}
Renderer.dict = {}

function Renderer:new()
  self.interest_id = {}
  self.interest_pivotdata = {}
  self.canvas = love.graphics.newCanvas()
  self.transform = nil
  self.x1 = 0
  self.x2 = 0
  self.y1 = 0
  self.y2 = 0

  self.width = 0
  self.height = 0

  self.owner = nil

  table.insert(Renderer.renderers_list, self)
end

-- class method
--#region



function Renderer.createpivot(graphical_id)
  local databox = Renderer.renderTarget_pivotmaker
  databox[graphical_id] = {nil, nil, nil,nil,nil, nil, nil} -- posx, posy, rotate, sizex, sizey, pivotamount
end

function Renderer.compensate(pos_x, pos_y,rotate, scale_x, scale_y, size_x, size_y,graphical_id)
  local valuetable = {pos_x, pos_y, rotate, scale_x, scale_y, size_x, size_y}
  local databox = Renderer.renderTarget_pivotmaker
  local maker = databox[graphical_id]
  for i = 1,7 do
    if valuetable[i] ~= nil then
      maker[i] = valuetable[i]
    end
  end
end

function Renderer.showFrame()
  for i=1,#Renderer.renderers_list do
    local Rs = Renderer.renderers_list[i]
    Rs:refresh()
    Rs:drawALL()
  end
  Renderer.Master:refresh()
  Renderer.Master:drawALL()
  love.graphics.push()
    Graphics.drawImmideatly(Renderer.Master.canvas, Renderer.Master.width, Renderer.Master.height, 0,0)
  love.graphics.pop()
end

--#endregion

-- instance method
--#region
function Renderer:equip(gbj,width, height) -- gbj can be nil.
  local center_x = 0
  local center_y = 0
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(width,height)
  if (gbj ~= nil) then
    local transforms = gbj.transform
    gbj.graphics:acceptNew(self.canvas)
    center_x = transforms.x
    center_y = transforms.y
    Renderer.Master:recept_directly(gbj)
    gbj.renderer = self
  end
  self.x1 = center_x - self.width / 2
  self.x2 = center_x + self.width / 2
  self.y1 = center_y - self.height / 2
  self.y2 = center_y + self.height / 2

  self.center_x = center_x
  self.center_y = center_y

  self.owner = gbj

  
end

function Renderer:resize(width, height,center_x, center_y) -- version for equip but not gbj included. raise error if equip() not already called. put nil value for not changing
  if center_x ~= nil then
    self.center_x = center_x
  end
  if center_y ~= nil then
    self.center_y = center_y
  end
  if width ~= nil then
    self.width = width
  end
  if height ~= nil then
    self.height = height
  end
  self.x1 = self.center_x - self.width / 2
  self.x2 = self.center_x + self.width / 2
  self.y1 = self.center_y - self.height / 2
  self.y2 = self.center_y + self.height / 2
end

function Renderer:recept_directly(gbj)
  local id = gbj.graphics.id
  if Renderer.renderTarget_pivotmaker[id] == nil then
      print("first create gbj.graphics then reception can complete(or first call Renderer.createpivot(id)). order rejected. ")
      print("remember : children gameobject's graphics components are not reception target.")
      return
  end
  table.insert(self.interest_id, id)
end

function Renderer:recept_automatically(gbj)
  local dic = clone.dictionalize(gbj)
  for i,gbj in ipairs(dic) do
    if gbj.graphics == nil then
      goto continues
    end
    local id = gbj.graphics.id
    if Renderer.renderTarget_pivotmaker[id] == nil then
        print("first create gbj.graphics then reception can complete(or first call Renderer.createpivot(id)). order rejected. ")
        return
    end
    table.insert(self.interest_id, id)
    ::continues::
  end
end

function Renderer:exclude(gbj)
  local tab = {}
  local excluded_id = gbj.graphics.id
  for i in ipairs(self.interest_id) do
    local id = self.interest_id[i]
    if id  ~= excluded_id then
      table.insert(tab, id)
    end
  end
  self.interest_id = tab
end

function Renderer:refresh()
  self.canvas = love.graphics.newCanvas(self.width,self.height)
  self.interest_pivotdata = {}

  local idS = self.interest_id
  local pivotS = self.interest_pivotdata
  for i=1, #idS do
    local id = idS[i]
    local databox = Renderer.renderTarget_pivotmaker
    local maker = databox[id]
    for i=1,4 do
      if maker[i] == nil then
        return
      end
    end
  
    local pos_x = maker[1]
    local pos_y = maker[2]
    local rotate = maker[3]
    local scale_x = maker[4]
    local scale_y = maker[5]
    local size_x = maker[6]
    local size_y = maker[7]

    
  
    pivotS[id.."-1"] = {pos_x - size_x*0.5*scale_x,pos_y + size_y*0.5*scale_y}--upleft
    pivotS[id.."-2"] = {pos_x + size_x*0.5*scale_x,pos_y + size_y*0.5*scale_y}--upright
    pivotS[id.."-3"] = {pos_x- size_x*0.5*scale_x,pos_y - size_y*0.5*scale_y}--downleft
    pivotS[id.."-4"] = {pos_x + size_x*0.5*scale_x,pos_y - size_y*0.5*scale_y}--downright
    if rotate ~= 0 then
      pivotS[id.."-1"] = linear.rotate({pos_x,pos_y},pivotS[id.."-1"],rotate)
      pivotS[id.."-2"] = linear.rotate({pos_x,pos_y},pivotS[id.."-2"],rotate)
      pivotS[id.."-3"] = linear.rotate({pos_x,pos_y},pivotS[id.."-3"],rotate)
      pivotS[id.."-4"] = linear.rotate({pos_x,pos_y},pivotS[id.."-4"],rotate)
    end
  end
  if self.owner ~= nil then
    self.owner.graphics:acceptNew(self.canvas)
  end
  
end

function Renderer:renderRectpivotDo(func)

  for id, valuebox in pairs(self.interest_pivotdata) do
    local x = valuebox[1]
    local y = valuebox[2]
    if self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2 then
      func(id)
    end
  end
end

function Renderer:renderRectIdDo(func)
  local idgetTable = {}
  
  for i=1,#self.interest_id do
    

    local id = self.interest_id[i]
    
    local pivots = {}
    table.insert(pivots, self.interest_pivotdata[id.."-1"])
    table.insert(pivots, self.interest_pivotdata[id.."-2"])
    table.insert(pivots, self.interest_pivotdata[id.."-3"])
    table.insert(pivots, self.interest_pivotdata[id.."-4"])
    -- if at least one pivot is inside the render_rect.
    for j=1,4 do
      local x = pivots[j][1]
      local y = pivots[j][2]
      if (self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2) then
        table.insert(idgetTable, id)
        goto continue
      end
    end
    local pivindex = {{1,2},{2,4},{4,3},{3,1}}
    local renderes = {{self.x1,self.y2},
                      {self.x2,self.y2},
                      {self.x1,self.y1},
                      {self.x2,self.y1}}
    
    -- if sprite edge and render_rect edge are crossing each other.
    for p=1,4 do
      for r=1,4 do
        local pnum = pivindex[p]
        local rnum = pivindex[r]
        local l1 = pivots[pnum[1]]
        local l2 = pivots[pnum[2]]
        local m1 = renderes[rnum[1]]
        local m2 = renderes[rnum[2]]
        if linear.islineCrossing(l1,l2,m1,m2) == true then
          table.insert(idgetTable, id)
          goto continue
        end
      end
    end
    -- if sprite_rect is so big that render_rect is inside of the sprite_rect.
    if linear.isPointInsideBox({self.x1,self.y1},pivots[1],pivots[2],pivots[4],pivots[3]) == true then
      table.insert(idgetTable, id)
      goto continue
    end
    --print(self.x1,self.y1,pivots[1][1],pivots[1][2],pivots[2][1],pivots[2][2],pivots[4][1],pivots[4][2],pivots[3][1],pivots[3][2])
    ::continue::
  end
  for num, id in ipairs(idgetTable) do
    func(id)
  end
end

function Renderer:drawboundray()
  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    love.graphics.rectangle("line",self.x1,self.y1,self.x2-self.x1,self.y2-self.y1)
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawSpritesPivot()
  local function idDo(id)
    local idbox = self.interest_pivotdata[id]
    local x = idbox[1]
    local y = idbox[2]
    love.graphics.rectangle("fill", x - self.x1, self.y2 - y, 1, 1)
    love.graphics.print(id,x - self.x1, self.y2 - y)
  end

  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    self:renderRectpivotDo(idDo)
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawALL()
  local function drawpos(id)
    local gbj = GameObject:find(GameObject:nameparse(id))
    local piv = Renderer.renderTarget_pivotmaker[id]
    love.graphics.draw(gbj.graphics.drawable, piv[1] - self.x1, self.y2 - piv[2], -piv[3], piv[4], piv[5], piv[6]*0.5, piv[7]*0.5)
  end

  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    self:renderRectIdDo(drawpos)
  love.graphics.pop()
  love.graphics.setCanvas()
end

Renderer.Master = Renderer()
--#endregion