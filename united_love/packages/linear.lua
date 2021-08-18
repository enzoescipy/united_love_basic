local Object = require "united_love.packages.classic"

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
        if l_start[2] <= y and y <= l_end[2] and m_start[2] <= y and y <= m_end[2] then
            return true
        else
            faultnum = 4
            goto fault
        end
    elseif x ~= nil then
        
        if l_start[1] <= x and x <= l_end[1] and m_start[1] <= x and x <= m_end[1] then 
            return true
        else
            faultnum = 5
        end
    else
        faultnum = 6
        goto fault
    end
    ::fault::
    return false
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

function linear.rotate(axis, target, angle) -- angle unit is radian.
    -- return rotated target point. orientation is axis value.
    if type(axis) ~= "table" or type(target) ~= "table" or type(angle) ~= "number" then
        return "type err."
    end
    local x = target[1] - axis[1]
    local y = target[2] - axis[2]

    local radious = math.sqrt(x*x + y*y)
    
    local current_angle = linear.toangle(x,y)
    local polar_P
    if current_angle == "origin" or radious == 0 then
        polar_P = {0,0}
    else
        polar_P = {radious, linear.toangle(x,y)}
    end

    polar_P[2] = polar_P[2] + angle
    local new_x = math.cos(polar_P[2]) * polar_P[1] + axis[1]
    local new_y = math.sin(polar_P[2]) * polar_P[1] + axis[2]
    return {new_x,new_y}
end

function linear.scale(origin, target, xscaleamount, yscaleamount)
    if type(origin) ~= "table" or type(target) ~= "table" or type(yscaleamount) ~= "number" or type(xscaleamount) ~= "number" then
        return "type err."
    end

    local abs_pos = {target[1] - origin[1], target[2] - origin[2]}
    return {abs_pos[1] * xscaleamount + origin[1], abs_pos[2] * yscaleamount + origin[2]}
end

function linear.angular_scale(origin, target, xscaleamount, yscaleamount, angle)
    if type(origin) ~= "table" or type(target) ~= "table" or type(yscaleamount) ~= "number" or type(xscaleamount) ~= "number" then
        return "type err."
    end

    local original_targetpos = linear.rotate(origin, target, -angle)
    local scaled_targetpos = linear.scale(origin, original_targetpos, xscaleamount, yscaleamount)
    return linear.rotate(origin, scaled_targetpos, angle)
end

function linear.toangle(x, y)
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
            return tanAngle + 2 * math.pi
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
end

function linear.Tmatrx:giveRotation(r)
    self.xVector = linear.rotate({0,0},self.xVector,-r)
    self.yVector = linear.rotate({0,0},self.yVector,-r)
end

function linear.Tmatrix:giveXscale(xs)
    self.xVector = linear.vectorScaling(self.xVector,xs)
end

function linear.Tmatrix:giveYscale(ys)
    self.yVector = linear.vectorScaling(self.yVector,ys)
end

function linear.Tmatrix:takeRotation(r)
    return - linear.toangle(self.xVector)
end

function linear.Tmatrix:takeXscale(xs)
    return linear.abs(self.xVector)
end

function linear.Tmatrix:takeYscale(ys)
    return linear.abs(self.yVector)
end


return linear