local linear = require "united_love.packages.linear"
local Tmatrix = linear.Tmatrix
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
  self.width = 0
  self.height = 0
  self.canvas_width = 0
  self.canvas_height = 0
  self.locational_gbj = nil
  self.transform = nil
  self.canvas_gbj = nil

  table.insert(Renderer.renderers_list, self)
end

-- class method
--#region



function Renderer.createpivot(graphical_id)
  local databox = Renderer.renderTarget_pivotmaker
  databox[graphical_id] = {nil, nil, nil,nil,nil, nil, nil} -- posx, posy, rotate, sizex, sizey, pivotamount
end

function Renderer.compensate(pos_x, pos_y,tMatrix, size_x, size_y,graphical_id)
  local valuetable
  if tMatrix == nil then
    valuetable = {pos_x, pos_y, tMatrix, size_x, size_y}
  else
    valuetable = {pos_x, pos_y, tMatrix:copy(), size_x, size_y}
  end
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

    --debugmode
    Rs:drawboundray(3)
    Rs:drawSpritesPivot()
    --end
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
function Renderer:equip(locational_gbj,canvas_gbj,width, height) -- locational_gbj can be nil. 
  -- equiped locational_gbj's transform.pos_abs[1], y, r will be rendering range rectangle's center position's x, y and rotation, xs and ys will be scaling of renderRect. 
  -- whatever you change xs or ys, xs and ys will be adjusted same, because of distortion of screen canvas.
  self.locational_gbj = locational_gbj
  self.canvas_gbj = canvas_gbj

  self.width = width
  self.height = height

  self.canvas_width = width
  self.canvas_height = height


  self.canvas = love.graphics.newCanvas(width,height)

  if (locational_gbj ~= nil and canvas_gbj ~= nil) then
    ---code for equalize xs and ys.
    self.transform = locational_gbj.transform
    canvas_gbj.graphics:acceptNew(self.canvas)
    Renderer.Master:recept_directly(canvas_gbj)
  else
    self.transform = {}
    self.transform.pos_abs = {0,0}
    self.transform.tMatrix = Tmatrix()
  end
end

function Renderer:refactor(width, height) -- version for equip but not gbj included. raise error if equip() not already called. put nil value for not changing
  if width ~= nil then
    self.width = width
  end
  if height ~= nil then
    self.height = height
  end
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

function Renderer:recept(gbj)
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

function Renderer:renderRectpivotCalculate()
  local center_x = self.transform.pos_abs[1]
  local center_y = self.transform.pos_abs[2]
  local x1 = center_x - self.width /2
  local x2 = center_x + self.width /2
  local y1 = center_y - self.height /2
  local y2 = center_y + self.height /2

  local renderRect_pivots = {{x1,y2},
                            {x2,y2},
                            {x1,y1},
                            {x2,y1}}
  
  local rotation = self.transform.tMatrix:takeRotation()
  if rotation ~= 0 then
    renderRect_pivots = {linear.centerVectorandMatrixMul({center_x,center_y},renderRect_pivots[1],self.transform.tMatrix),
                        linear.centerVectorandMatrixMul({center_x,center_y},renderRect_pivots[2],self.transform.tMatrix),
                        linear.centerVectorandMatrixMul({center_x,center_y},renderRect_pivots[3],self.transform.tMatrix),
                        linear.centerVectorandMatrixMul({center_x,center_y},renderRect_pivots[4],self.transform.tMatrix)}
  end

  return renderRect_pivots
end

function Renderer:refresh()
  self.canvas = love.graphics.newCanvas(self.canvas_width, self.canvas_height)
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
    local pos = {pos_x,pos_y}
    local tMatrix = maker[3]:copy()
    local size_x = maker[4]
    local size_y = maker[5]

    

    pivotS[id.."-1"] = {- size_x/2, size_y/2}--upleft
    pivotS[id.."-2"] = { size_x/2, size_y/2}--upright
    pivotS[id.."-3"] = { -size_x/2, - size_y/2}--downleft
    pivotS[id.."-4"] = { size_x/2, - size_y/2}--downright

    pivotS[id.."-1"] = linear.vectorAdd(linear.matVecMul(pivotS[id.."-1"],tMatrix),pos)
    pivotS[id.."-2"] = linear.vectorAdd(linear.matVecMul(pivotS[id.."-2"],tMatrix),pos)
    pivotS[id.."-3"] = linear.vectorAdd(linear.matVecMul(pivotS[id.."-3"],tMatrix),pos)
    pivotS[id.."-4"] = linear.vectorAdd(linear.matVecMul(pivotS[id.."-4"],tMatrix),pos)
  end
  if self.canvas_gbj ~= nil then
    self.canvas_gbj.graphics:acceptNew(self.canvas)
  end
  
end

function Renderer:renderRectpivotDo(func)
  for id, valuebox in pairs(self.interest_pivotdata) do
    local renderer_Rect_pivot = self:renderRectpivotCalculate()
    if linear.isPointInsideBox({self.transform.pos_abs[1],self.transform.pos_abs[2]},renderer_Rect_pivot[1],renderer_Rect_pivot[2],renderer_Rect_pivot[4],renderer_Rect_pivot[3]) == true then
      func(id)
    end
  end
end

function Renderer:renderRectIdDo(func)
  local idgetTable = {}
  
  for i=1,#self.interest_id do
    --12 24 43 31

    local id = self.interest_id[i]
    
    local pivots = {}
    table.insert(pivots, self.interest_pivotdata[id.."-1"])
    table.insert(pivots, self.interest_pivotdata[id.."-2"])
    table.insert(pivots, self.interest_pivotdata[id.."-3"])
    table.insert(pivots, self.interest_pivotdata[id.."-4"])
    local renderer_pivots = self:renderRectpivotCalculate()

    -- check if renderRect and spriteRect are overwrapping each other, by using Area-vectorpair.
    local renderRect = linear.point4ToRectanglularArea(renderer_pivots[1],renderer_pivots[2],renderer_pivots[3],renderer_pivots[4])
    local spriteRect = linear.point4ToRectanglularArea(pivots[1],pivots[2],pivots[3],pivots[4])
    if linear.isvectorPairOverwrappedTrue(renderRect, spriteRect) == true then
      func(id)
    end
  end
end

function Renderer:drawboundray(thickness)
  local scaled_w = (self.width * self.transform.tMatrix:takeXscale())
  local scaled_h = (self.height * self.transform.tMatrix:takeYscale())
  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
  love.graphics.scale(self.canvas_width / scaled_w ,self.canvas_height / scaled_h)
    love.graphics.rectangle("fill", 0,0,scaled_w,thickness)
    love.graphics.rectangle("fill", 0,0,thickness,scaled_h)
    love.graphics.rectangle("fill", 0,scaled_h - thickness,scaled_w,scaled_h)
    love.graphics.rectangle("fill", scaled_w - thickness,0,scaled_w,scaled_h)
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawSpritesPivot()
  local function idDo(id)
    local piv = self.interest_pivotdata[id]
    local xp = piv[1]
    local yp = piv[2]
    local pos = {xp-self.transform.pos_abs[1], yp-self.transform.pos_abs[2]}

    local corrected_piv = {linear.innerproduct(pos,self.transform.tMatrix.xVector),
                          linear.innerproduct(pos,self.transform.tMatrix.yVector)}

    corrected_piv[1] = self.width/2 + corrected_piv[1] 
    corrected_piv[2] = self.height/2 + corrected_piv[2]

    love.graphics.rectangle("fill", corrected_piv[1], corrected_piv[2], 1, 1)
    
    love.graphics.print(id,corrected_piv[1], corrected_piv[2])
  end

  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
  love.graphics.scale(self.canvas_width / (self.width * self.transform.tMatrix:takeXscale()), 
  self.canvas_height / (self.height * self.transform.tMatrix:takeYscale()))
    self:renderRectpivotDo(idDo)
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawALL()
  local function drawpos(id)
    local gbj = GameObject:find(GameObject:nameparse(id))
    local piv = Renderer.renderTarget_pivotmaker[id]
    local xp = piv[1]
    local yp = piv[2]

    local pos = {xp-self.transform.pos_abs[1], yp-self.transform.pos_abs[2]}

    local corrected_piv = {linear.innerproduct(pos,self.transform.tMatrix.xVector),
                          linear.innerproduct(pos,self.transform.tMatrix.yVector), 
                          piv[3]:takeRotation(), piv[3]:takeXscale(), piv[3]:takeYscale(), piv[4]*0.5, piv[5]*0.5}
    corrected_piv[1] = self.width/2 + corrected_piv[1] 
    corrected_piv[2] = self.height/2 + corrected_piv[2]
    corrected_piv[3] = corrected_piv[3] - self.transform.tMatrix:takeRotation()
    love.graphics.draw(gbj.graphics.drawable, 
                       corrected_piv[1], 
                       corrected_piv[2], 
                       corrected_piv[3], 
                       corrected_piv[4], 
                       corrected_piv[5], 
                       corrected_piv[6], 
                       corrected_piv[7])
    --print(corrected_piv[1], corrected_piv[2])
    
  end

  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    love.graphics.scale(self.canvas_width / (self.width * self.transform.tMatrix:takeXscale()), 
                        self.canvas_height / (self.height * self.transform.tMatrix:takeYscale()))
    self:renderRectIdDo(drawpos)
  love.graphics.pop()
  love.graphics.setCanvas()
end

Renderer.Master = Renderer()
--#endregion