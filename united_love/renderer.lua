local linear = require "united_love.packages.linear"
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
end

-- class method
--#region
function Renderer.createpivot(graphical_id)
  local databox = Renderer.renderTarget_pivotmaker
  databox[graphical_id] = {nil, nil, nil,nil,nil, nil, nil} -- posx, posy, sizex, sizey, pivotamount
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
--[[
function Renderer.calculateALL()
  local idS = Renderer.renderTarget_id_SUPER
  for i=1, #idS do
    local id = idS[i]
    local databox = Renderer.renderTarget_pivotdata_SUPER
    local maker = databox[id]
    for i=1,4 do
      if maker[i] == nil then
        return
      end
    end
  
    local pos_x = maker[1]
    local pos_y = maker[2]
    local size_x = maker[3]
    local size_y = maker[4]
  
    databox[id.."-1"] = {pos_x,pos_y}
    databox[id.."-2"] = {pos_x + size_x,pos_y}
    databox[id.."-3"] = {pos_x,pos_y + size_y}
    databox[id.."-4"] = {pos_x + size_x,pos_y+size_y}
  end

end
]]
--#endregion

-- instance method
--#region
function Renderer:origin(gbj,width, height)
  self.transform = gbj.transform
  self.width = width
  self.height = height
  local center_x = self.transform.x
  local center_y = self.transform.y
  self.x1 = center_x - self.width / 2
  self.x2 = center_x + self.width / 2
  self.y1 = center_y - self.height / 2
  self.y2 = center_y + self.height / 2
end

function Renderer:recept(gbj)
  local id = gbj.graphics.id
  if Renderer.renderTarget_pivotmaker[id] == nil then
      print("first create gbj.graphics then reception can complete(or first call Renderer.createpivot(id)). order rejected. ")
      print("remember : children gameobject's graphics components are not reception target.")
      return
  end
  table.insert(self.interest_id, id)
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
  self.canvas = love.graphics.newCanvas()
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
  
    pivotS[id.."-1"] = {pos_x - size_x*0.5*scale_x,pos_y + size_y*0.5*scale_y}
    pivotS[id.."-2"] = {pos_x + size_x*0.5*scale_x,pos_y + size_y*0.5*scale_y}
    pivotS[id.."-3"] = {pos_x- size_x*0.5*scale_x,pos_y - size_y*0.5*scale_y}
    pivotS[id.."-4"] = {pos_x + size_x*0.5*scale_x,pos_y - size_y*0.5*scale_y}
    if rotate ~= 0 then
      pivotS[id.."-1"] = linear.rotate({pos_x,pos_y},pivotS[id.."-1"],rotate)
      pivotS[id.."-2"] = linear.rotate({pos_x,pos_y},pivotS[id.."-2"],rotate)
      pivotS[id.."-3"] = linear.rotate({pos_x,pos_y},pivotS[id.."-3"],rotate)
      pivotS[id.."-4"] = linear.rotate({pos_x,pos_y},pivotS[id.."-4"],rotate)
    end
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
  for id, valuebox in pairs(self.interest_pivotdata) do
    local x = valuebox[1]
    local y = valuebox[2]
    if not (self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2) then
      goto continue
    end
    local id_real = string.sub(id, 1,string.len(id)-2)
    if idgetTable[id_real] == nil then
      idgetTable[id_real] = 1
    else
      idgetTable[id_real] = idgetTable[id_real] + 1
    end
    ::continue::
  end
  for idreal, pivotcount in pairs(idgetTable) do
    func(idreal)
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

function Renderer:getcanvas()
  return self.canvas
end

--#endregion