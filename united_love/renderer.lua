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
  -- equiped locational_gbj's transform.x, y, r will be rendering range rectangle's center position's x, y and rotation, xs and ys will be scaling of renderRect. 
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
    self.transform.x = 0
    self.transform.y = 0
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

function Renderer:scaledW()
  return self.width * self.transform.tMatrix:takeXscale()
end

function Renderer:scaledH()
  return self.height * self.transform.tMatrix:takeYscale()
end

function Renderer:renderRectpivotCalculate()
  local center_x = self.transform.x
  local center_y = self.transform.y
  local x1 = center_x - self:scaledW() /2
  local x2 = center_x + self:scaledW() /2
  local y1 = center_y - self:scaledH() /2
  local y2 = center_y + self:scaledH() /2

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
    local tMatrix = maker[3]:copy()
    local size_x = maker[4]
    local size_y = maker[5]

    

    pivotS[id.."-1"] = {pos_x - size_x/2,pos_y + size_y/2}--upleft
    pivotS[id.."-2"] = {pos_x + size_x/2,pos_y + size_y/2}--upright
    pivotS[id.."-3"] = {pos_x- size_x/2,pos_y - size_y/2}--downleft
    pivotS[id.."-4"] = {pos_x + size_x/2,pos_y - size_y/2}--downright

    pivotS[id.."-1"] = linear.centerVectorandMatrixMul({pos_x,pos_y},pivotS[id.."-1"],tMatrix)
    pivotS[id.."-2"] = linear.centerVectorandMatrixMul({pos_x,pos_y},pivotS[id.."-2"],tMatrix)
    pivotS[id.."-3"] = linear.centerVectorandMatrixMul({pos_x,pos_y},pivotS[id.."-3"],tMatrix)
    pivotS[id.."-4"] = linear.centerVectorandMatrixMul({pos_x,pos_y},pivotS[id.."-4"],tMatrix)
  end
  if self.canvas_gbj ~= nil then
    self.canvas_gbj.graphics:acceptNew(self.canvas)
  end
  
end

function Renderer:renderRectpivotDo(func)
  for id, valuebox in pairs(self.interest_pivotdata) do
    local renderer_Rect_pivot = self:renderRectpivotCalculate()
    if linear.isPointInsideBox({self.transform.x,self.transform.y},renderer_Rect_pivot[1],renderer_Rect_pivot[2],renderer_Rect_pivot[4],renderer_Rect_pivot[3]) == true then
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

    local renderer_Rect_pivot = self:renderRectpivotCalculate()


    -- if at least one pivot is inside the render_rect or 
    for j=1,4 do
      local x = pivots[j][1]
      local y = pivots[j][2]
      if linear.isPointInsideBox({x,y},renderer_Rect_pivot[1],renderer_Rect_pivot[2],renderer_Rect_pivot[4],renderer_Rect_pivot[3]) == true then
        table.insert(idgetTable, id)
        goto continue
      end
    end

    
    -- if sprite edge and render_rect edge are crossing each other.
    local pivindex = {{1,2},{2,4},{4,3},{3,1}} 
    for p=1,4 do
      for r=1,4 do
        local pnum = pivindex[p]
        local rnum = pivindex[r]
        local l1 = pivots[pnum[1]]
        local l2 = pivots[pnum[2]]
        local m1 = renderer_Rect_pivot[rnum[1]]
        local m2 = renderer_Rect_pivot[rnum[2]]
        if linear.islineCrossing(l1,l2,m1,m2) == true then
          table.insert(idgetTable, id)
          goto continue
        end
      end
    end
    -- ... sprite_rect is so big that render_rect is inside of the sprite_rect.
    if linear.isPointInsideBox(self:renderRectpivotCalculate()[1],pivots[1],pivots[2],pivots[4],pivots[3]) == true then
      table.insert(idgetTable, id)
      goto continue
    end
    
    --print(renderer_Rect_pivot[1][1],renderer_Rect_pivot[1][2],renderer_Rect_pivot[2][1],renderer_Rect_pivot[2][2],renderer_Rect_pivot[3][1],renderer_Rect_pivot[3][2])
    ::continue::
  end
  for num, id in ipairs(idgetTable) do
    func(id)
  end
end

function Renderer:drawboundray(thickness)
  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    love.graphics.scale(self.canvas_width / self:scaledW(), self.canvas_height / self:scaledH())
    love.graphics.rectangle("fill", 0,0,self:scaledW(),thickness)
    love.graphics.rectangle("fill", 0,0,thickness,self:scaledH())
    love.graphics.rectangle("fill", 0,self:scaledH() - thickness,self:scaledW(),self:scaledH())
    love.graphics.rectangle("fill", self:scaledW() - thickness,0,self:scaledW(),self:scaledH())
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawSpritesPivot()
  local function idDo(id)
    local piv = self.interest_pivotdata[id]
    local renderer_piv = self:renderRectpivotCalculate()
    local renderRects = {renderer_piv[3],renderer_piv[2]}
    local x1 = renderRects[1][1]
    local x2 = renderRects[2][1]
    local y1 = renderRects[1][2]
    local y2 = renderRects[2][2]
    local xp = piv[1]
    local yp = piv[2]
    local corrected_piv = {(xp - x1), (yp - y1)}
    local rotated_pos = linear.centerVectorandMatrixMul({(x1+x2)/2, (y1+y2)/2}, {corrected_piv[1],corrected_piv[2]}, self.transform.tMatrix)
    
    corrected_piv[1] = rotated_pos[1]
    corrected_piv[2] = rotated_pos[2]
    love.graphics.rectangle("fill", corrected_piv[1], corrected_piv[2], 1, 1)
    
    love.graphics.print(id,corrected_piv[1], corrected_piv[2])
  end

  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
    love.graphics.scale(self.canvas_width / self:scaledW(), self.canvas_height / self:scaledH())
    self:renderRectpivotDo(idDo)
  love.graphics.pop()
  love.graphics.setCanvas()
end

function Renderer:drawALL()
  local function drawpos(id)
    local gbj = GameObject:find(GameObject:nameparse(id))
    local piv = Renderer.renderTarget_pivotmaker[id]
    local renderer_piv = self:renderRectpivotCalculate()
    local renderRects = {renderer_piv[3],renderer_piv[2]}
    local x1 = renderRects[1][1]
    local x2 = renderRects[2][1]
    local y1 = renderRects[1][2]
    local y2 = renderRects[2][2]
    local xp = piv[1]
    local yp = piv[2]
    local corrected_piv = {(xp - x1), (yp - y1), piv[3]:takeRotation(), piv[3]:takeXscale(), piv[3]:takeYscale(), piv[4]*0.5, piv[5]*0.5}
    local rotated_pos = linear.centerVectorandMatrixMul({(x1+x2)/2, (y1+y2)/2}, {corrected_piv[1],corrected_piv[2]}, self.transform.tMatrix)
    corrected_piv[1] = rotated_pos[1]
    corrected_piv[2] = rotated_pos[2]
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
    love.graphics.scale(self.canvas_width / self:scaledW(), self.canvas_height / self:scaledH())
    self:renderRectIdDo(drawpos)
  love.graphics.pop()
  love.graphics.setCanvas()
end

Renderer.Master = Renderer()
--#endregion