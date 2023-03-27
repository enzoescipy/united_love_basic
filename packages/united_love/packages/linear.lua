local Object = require "packages.united_love.packages.classic"

local linear = {}

local FLANK = 0.00000000001
local INF = 1/0
local NAN = 0/0
linear.FLANK = FLANK
linear.INF = INF
linear.NAN = NAN

function linear.abs(v)
    local x = v[1]
    local y = v[2]
    return math.sqrt(x*x + y*y)
end

function linear.plusminusFlip(v)
    return {-v[1],-v[2]}
end

function linear.vectorAdd(v1,v2)
    return {v1[1]+v2[1],v1[2]+v2[2]}
end

function linear.vectorScaling(v1, s)
    return {v1[1]*s,v1[2]*s}
end

function linear.innerproduct(v1,v2)
    return v1[1]*v2[1] + v1[2]*v2[2]
end

function linear.pointToPointDist(p1,p2)
    return math.sqrt((p1[1]-p2[1]) * (p1[1]-p2[1]) + (p1[2]-p2[2]) * (p1[2]-p2[2]))
end

function linear.pointToPointDistSquared(p1,p2) -- faster ver. of linear.pointToPointDist(...)
    return (p1[1]-p2[1]) * (p1[1]-p2[1]) + (p1[2]-p2[2]) * (p1[2]-p2[2])
end

function linear.islineCrossing(l_start,l_end,m_start,m_end,...) -- each vars are table {1.0,2.3, ... } represent a vector.
    -- check if two lines crossing each other.
    if type(l_start) ~= "table" or type(l_end) ~= "table" or type(m_start) ~= "table" or type(m_end) ~= "table" then
        return "type err."
    end
    local faultnum
    local x
    local y
    local l_slope = (l_end[2] - l_start[2]) / (l_end[1] - l_start[1])
    local m_slope = (m_end[2] - m_start[2]) / (m_end[1] - m_start[1])
    local abs_lsp = math.abs(l_slope)
    local abs_msp = math.abs(m_slope)
    if abs_lsp == INF or abs_msp == INF then
        if abs_lsp == INF then
            l_slope = "INF"
            abs_lsp = "INF"
            m_slope = (m_end[2] - m_start[2]) / (m_end[1] - m_start[1])
        elseif abs_msp == INF then
            m_slope = "INF"
            abs_msp = "INF"
            l_slope = (l_end[2] - l_start[2]) / (l_end[1] - l_start[1])
        else
            faultnum = 1
            goto fault
        end
    end
    
    if abs_lsp == "INF" or abs_msp == "INF" then
        
        if abs_lsp == "INF" then
            
            y = m_slope*(l_start[1] - m_start[1]) + m_start[2]
        elseif abs_msp == "INF" then
            y = l_slope*(m_start[1] - l_start[1]) + l_start[2]
        else
            faultnum = 2
            goto fault -- two lines are parallel.
            
        end
    elseif abs_lsp <= FLANK or abs_msp <= FLANK then
        
        if abs_lsp <= FLANK then
            
            x = (m_slope*m_start[1] - m_start[2] + l_start[2]) / m_slope
        elseif abs_msp <= FLANK then
            x = (l_slope*l_start[1] - l_start[2] + m_start[2]) / l_slope
        else
            faultnum = 3
            goto fault -- two lines are parallel.
        end
    else
        x = ((l_slope*l_start[1]-m_slope*m_start[1]) - (l_start[2]-m_start[2])) / (l_slope - m_slope)
    end
    
    if y ~= nil then
        local ly1 = l_start[2] 
        local ly2 = l_end[2]
        local my1 = m_start[2]
        local my2 = m_end[2]
        if l_start[2] > l_end[2] then
            local temp = ly1
            ly2 = ly1
            ly1 = temp
        end
        if m_start[2] > m_end[2] then
            local temp = my1
            my2 = my1
            my1 = temp
        end 
        if ly1 <= y and y <= ly2 and my1 <= y and y <= my2 then
            return true
        else
            faultnum = 4
            goto fault
        end
    elseif x ~= nil then
        local lx1 = l_start[1] 
        local lx2 = l_end[1]
        local mx1 = m_start[1]
        local mx2 = m_end[1]
        if l_start[1] > l_end[1] then
            local temp = lx1
            lx2 = lx1
            lx1 = temp
        end
        if m_start[1] > m_end[1] then
            local temp = mx1
            mx2 = mx1
            mx1 = temp
        end 
        if lx1 <= x and x <= lx2 and mx1 <= x and x <= mx2 then 
            return true
        else
            faultnum = 5
            goto fault
        end
    else
        faultnum = 6
        goto fault
    end
    ::fault::
    --print(math.floor(l_start[1]),math.floor(l_end[1]),math.floor(m_start[1]),math.floor(m_end[1]))
    --print(math.floor(l_start[2]),math.floor(l_end[2]),math.floor(m_start[2]),math.floor(m_end[2]))
    return false
end

function linear.point2toline(l_start,l_end) -- returns if result is ax+b => {a,b}
    -- check if two lines crossing each other.
    if type(l_start) ~= "table" or type(l_end) ~= "table" then
        return "type err."
    end
    local faultnum
    local x
    local y
    local l_slope = (l_end[2] - l_start[2]) / (l_end[1] - l_start[1])
    local abs_lsp = math.abs(l_slope)
    if abs_lsp == INF then
        return {l_start[1],0}
    elseif abs_lsp <= FLANK then
        return {0,l_start[2]}
    else
        return {l_slope,-l_slope*l_start[1]+l_start[2]}
    end
end

function linear.lineToPointDist(point, l_start, l_end,...)
    local error_tolerate = {...}
    error_tolerate = error_tolerate[1]
    if error_tolerate == nil then
        error_tolerate = FLANK
    end

    if type(l_start) ~= "table" or type(l_end) ~= "table" or type(point) ~= "table" then
        return "type err."
    end
    local x_delta = math.abs(l_end[1] - l_start[1])
    local y_delta = math.abs(l_end[2] - l_start[2])
    if x_delta <= error_tolerate or y_delta <= error_tolerate then
        if x_delta <= error_tolerate then
            return math.abs(l_start[1] - point[1])
        end
        if y_delta <= error_tolerate then
            return math.abs(l_start[2] - point[2])
            
        end
    else
        local slope = (l_end[2] - l_start[2]) / (l_end[1] - l_start[1])
    end
        
    local slope = (l_end[2] - l_start[2]) / (l_end[1] - l_start[1])
    local value = math.abs(slope*point[1] - point[2] - slope*l_start[1] + l_start[2])
    local dist = math.sqrt(slope*slope + 1)
    -- line => slope*x - y - slope*k + f(k) = 0
    if dist ~= 1/0 then
        return value / dist
    else
        return 0
    end
end

function linear.isPointInsideBox(point, p1,p2,p3,p4,...) -- box must be perfect rectangle. error toleration can be added last parameter. p1->p2->p3->p4 line are MUST making a closed loop. <<NOT>> be like : {-1,1},{1,1},{-1,-1},{1,-1} 
    local error_tolerate = {...}
    error_tolerate = error_tolerate[1]
    if error_tolerate == nil then
        error_tolerate = FLANK
    end

    local length = 0
    length = length + linear.lineToPointDist(point, p1, p2)
    length = length + linear.lineToPointDist(point, p2, p3)
    length = length + linear.lineToPointDist(point, p3, p4)
    length = length + linear.lineToPointDist(point, p4, p1)

    local round = 0
    round = round + linear.pointToPointDist(p1,p2)
    round = round + linear.pointToPointDist(p2,p3)
    round = round + linear.pointToPointDist(p3,p4)
    round = round + linear.pointToPointDist(p4,p1)
    round = round / 2

    if math.abs(round - length) <= error_tolerate then
        return true
    else
        
        return false
    end

end


function linear.toangle(x, y) -- toangle return right-handed angle.
    local tanAngle = 0.0
    if x == 0.0 then
        if y > 0 then
            tanAngle = math.pi / 2
        elseif y < 0 then
            tanAngle = - math.pi / 2
        else
            return "origin"
        end
    else
        tanAngle = math.atan(y/x)
    end

    if tanAngle > 0 then
        if x >= 0 then
            return tanAngle
        else
            return tanAngle + math.pi
        end
    elseif tanAngle < 0 then
        if y < 0 then
            return tanAngle
        else
            return tanAngle + math.pi
        end
    else
        return 0.0
    end
end

linear.Tmatrix = Object:extend()

function linear.Tmatrix:new()
    self.xVector = {1,0}
    self.yVector = {0,1}
    self.type = "Matrix"
end

function linear.Tmatrix:copy()
    local result = linear.Tmatrix()
    result.xVector[1] = self.xVector[1]
    result.xVector[2] = self.xVector[2]
    result.yVector[1] = self.yVector[1]
    result.yVector[2] = self.yVector[2]
    return result
end

function linear.Tmatrix:debug()
    local t = {self.xVector[1],self.yVector[1],
                self.xVector[2],self.yVector[2]}
    print("{"..tostring(t[1])..", "..tostring(t[2]).."}")
    print("{"..tostring(t[3])..", "..tostring(t[4]).."}")
end

function linear.Tmatrix:getRotated(r)
    local result = linear.Tmatrix()
    local function rotation(v, r)
        local cos, sin = math.cos(r),math.sin(r)
        local rotMatrix = linear.Tmatrix()
        rotMatrix.xVector = {cos,sin}
        rotMatrix.yVector = {-sin,cos}
        return linear.matVecMul(v,rotMatrix)
    end
    local temp_x = rotation(self.xVector,r)
    local temp_y = rotation(self.yVector,r)
    result.xVector = temp_x
    result.yVector = temp_y
    return result
end

function linear.Tmatrix:getXscaled(xs)
    local result = linear.Tmatrix()
    result.xVector = linear.vectorScaling(self.xVector,xs)
    return result
end

function linear.Tmatrix:getYscaled(ys)
    local result = linear.Tmatrix()
    result.yVector = linear.vectorScaling(self.yVector,ys)
    return result
end

function linear.Tmatrix:getEvenlyscaled(s)
    local result = linear.Tmatrix()
    result.xVector = linear.vectorScaling(self.xVector,s)
    result.yVector = linear.vectorScaling(self.yVector,s)
    return result
end

function linear.Tmatrix:takeRotation(r)
    return linear.toangle(self.xVector[1],self.xVector[2])
end

function linear.Tmatrix:takeXscale(xs)
    return linear.abs(self.xVector)
end

function linear.Tmatrix:takeYscale(ys)
    return linear.abs(self.yVector)
end

function linear.Tmatrix:takeInverse(...) -- ... means error tolerlrate, for not defined inverse matrix select range.
    local error_tolerate = {...}
    error_tolerate = error_tolerate[1]
    if error_tolerate == nil then
        error_tolerate = FLANK
    end
    local t = {self.xVector[1],self.yVector[1],
                self.xVector[2],self.yVector[2]}
    local determinant = t[1]*t[4] - t[2]*t[3]
    if math.abs(determinant) <= error_tolerate then
        return "NOT_DEFINED"
    end
    determinant = 1 / determinant
    local resultT = {determinant*t[4],-determinant*t[2],
                     -determinant*t[3],determinant*t[1]}
    local result = linear.Tmatrix()
    result.xVector = {resultT[1],resultT[3]}
    result.yVector = {resultT[2],resultT[4]}
    return result
end

function linear.Tmatrix:det()
    local t = {self.xVector[1],self.yVector[1],
                self.xVector[2],self.yVector[2]}
    local determinant = t[1]*t[4] - t[2]*t[3]
    return determinant
end

function linear.matrixMul(tma1, tma2)
    local result = linear.Tmatrix()
    local t1 = {tma1.xVector[1],tma1.yVector[1],
                tma1.xVector[2],tma1.yVector[2]}
    local t2 = {tma2.xVector[1],tma2.yVector[1],
                tma2.xVector[2],tma2.yVector[2]}

    local resultMatrix = {t1[1]*t2[1]+t1[2]*t2[3]  ,  t1[1]*t2[2]+t1[2]*t2[4],
                          t1[3]*t2[1]+t1[4]*t2[3]  ,  t1[3]*t2[2]+t1[4]*t2[4]}

    result.xVector = {resultMatrix[1],resultMatrix[2]}
    result.yVector = {resultMatrix[3],resultMatrix[4]}
    return result
end

function linear.matVecMul(vec, mat)
    local result = {0,0}
    local v = vec
    local m = {mat.xVector[1],mat.yVector[1],
                mat.xVector[2],mat.yVector[2]}
    result[1] = m[1]*v[1] + m[2]*v[2]
    result[2] = m[3]*v[1] + m[4]*v[2]

    return result
end

function linear.centerVectorandMatrixMul(centerVec, targetVec, Matrix)
    local realTarget =  linear.vectorAdd(linear.plusminusFlip(centerVec), targetVec)
    return linear.vectorAdd(linear.matVecMul(realTarget, Matrix),centerVec)
end


linear.vectorPair_linear = Object:extend() --using expression for area, and area-collision checking. for more informations, please read documments...

function linear.vectorPair_linear:new(xrange1,xrange2)
    self.xRange = {xrange1,xrange2}
    self.yStartfunc = {}
    self.yEndfunc = {}
end

function linear.vectorPair_linear:yStartNew(startX, a,b) -- ax + b = y
    local data = {startX,a,b}
    table.insert(self.yStartfunc, data)
end

function linear.vectorPair_linear:yEndNew(startX, a,b) -- ax + b = y
    local data = {startX,a,b}
    table.insert(self.yEndfunc, data)
end

function linear.vectorPair_linear:yStart_simpleTrioAdd(y1,midpoint,y2)
    local l1 = linear.point2toline({self.xRange[1],y1},midpoint)
    local l2 = linear.point2toline(midpoint,{self.xRange[2],y2})
    self:yStartNew(self.xRange[1],l1[1],l1[2])
    self:yStartNew(midpoint[1],l2[1],l2[2])
end

function linear.vectorPair_linear:yEnd_simpleTrioAdd(y1,midpoint,y2)
    local l1 = linear.point2toline({self.xRange[1],y1},midpoint)
    local l2 = linear.point2toline(midpoint,{self.xRange[2],y2})
    self:yEndNew(self.xRange[1],l1[1],l1[2])
    self:yEndNew(midpoint[1],l2[1],l2[2])
end

function linear.point4ToRectanglularArea(p1,p2,p3,p4)
    local pivots = {p1,p2,p3,p4}
    local orthogonal = false
    table.sort(pivots, function (a, b)
      if a[1] < b[1] then
        return true
      end
      return false
    end)
    local XrangePoint
    if math.abs(pivots[1][1] - pivots[2][1]) <= FLANK or math.abs(pivots[3][1] - pivots[4][1]) <= FLANK then
        XrangePoint = {pivots[1][1],pivots[4][1]}
        orthogonal = true
    else
        XrangePoint = {pivots[1],pivots[4]}
    end
    

    table.sort(pivots, function (a, b)
      if a[2] < b[2] then
        return true
      end
      return false
    end)
    local YrangePoint
    if math.abs(pivots[1][2] - pivots[2][2]) <= FLANK or math.abs(pivots[3][2] - pivots[4][2]) <= FLANK then
        YrangePoint = {pivots[1][2],pivots[4][2]}
        orthogonal = true
    else
        YrangePoint = {pivots[1],pivots[4]}
    end

    local Rectresult
    if orthogonal == false then
        Rectresult = linear.vectorPair_linear(XrangePoint[1][1],XrangePoint[2][1])
        Rectresult:yStart_simpleTrioAdd(XrangePoint[1][2],YrangePoint[1],XrangePoint[2][2])
        Rectresult:yEnd_simpleTrioAdd(XrangePoint[1][2],YrangePoint[2],XrangePoint[2][2])
    else
        Rectresult = linear.vectorPair_linear(XrangePoint[1],XrangePoint[2])
        Rectresult:yStartNew(XrangePoint[1],0,YrangePoint[1])
        Rectresult:yEndNew(XrangePoint[1],0,YrangePoint[2])
    end


    return Rectresult
    
end

function linear.isvectorPairOverwrappedTrue(vep1, vep2,...)
    local error_tolerate = {...}
    error_tolerate = error_tolerate[1]
    if error_tolerate == nil then
        error_tolerate = FLANK
    end

    if  (vep1.xRange[1] < vep2.xRange[2] or vep2.xRange[1] < vep1.xRange[2]) ~= true then
        return false --means not overwrapped.
    end

    local function rap(v1, v2)
        local ydiffrange_collect = {}
        local v1_startX_indexer = {}
        local v2_startX_indexer = {}
        local delta_collect = {}
        for i,v in ipairs(v1.yEndfunc) do
            table.insert(ydiffrange_collect, v[1])
            v1_startX_indexer[v[1]] = {v[2],v[3]}
        end
        --[=[
        local lastyendfunc = v1.yEndfunc[#v1.yEndfunc]
        table.insert(ydiffrange_collect, v1.xRange[2])
        v1_startX_indexer[v1.xRange[2]] = {lastyendfunc[2],lastyendfunc[3]}"
        ]=]
        for i,v in ipairs(v2.yStartfunc) do
            table.insert(ydiffrange_collect, v[1])
            v2_startX_indexer[v[1]] = {v[2],v[3]}
        end
        --[=[
        local lastystartfunc = v2.yStartfunc[#v2.yStartfunc]
        table.insert(ydiffrange_collect, v2.xRange[2])
        v2_startX_indexer[v2.xRange[2]] = {lastystartfunc[2],lastystartfunc[3]}
        ]=]
        table.sort(ydiffrange_collect)
        

        local valuebefore = nil
    
        for i=1,#ydiffrange_collect do
            local v = ydiffrange_collect[i]
            if v == valuebefore then
                goto continues
            end
            local v1func = v1_startX_indexer[v]
            local v2func = v2_startX_indexer[v]
            if  v1func ~= nil and v2func ~= nil then
                local delta = {v,v2func[1] - v1func[1],v2func[2] - v1func[2]}
                table.insert(delta_collect,delta)
            elseif v1func ~= nil and v2func == nil and v2.xRange[1] <= v and v <= v2.xRange[2] then
                local v2func
                for alt=#ydiffrange_collect - 1,1,-1 do
                    v2func = v2_startX_indexer[ydiffrange_collect[alt]]
                    if v2func ~= nil then
                        break
                    end
                end
                local delta = {v,v2func[1] - v1func[1],v2func[2] - v1func[2]}
                table.insert(delta_collect,delta)
            elseif v1func == nil and v2func ~= nil and v1.xRange[1] <= v and v <= v1.xRange[2] then
                local v1func
                for alt=#ydiffrange_collect - 1,1,-1 do
                    v1func = v1_startX_indexer[ydiffrange_collect[alt]]
                    if v1func ~= nil then
                        break
                    end
                end
                local delta = {v,v2func[1] - v1func[1],v2func[2] - v1func[2]}
                table.insert(delta_collect,delta)
            end
            valuebefore = v
            ::continues::
        end
    
        for i,delta in ipairs(delta_collect) do
            local rangevalue = delta[1] * delta[2] + delta[3]
            if rangevalue < - error_tolerate then
                return true
            end
        end
    end
    if rap(vep1, vep2) then
        return true
    end

    if rap(vep2, vep1)  then
        return true
    end
    
    return false
end


return linear