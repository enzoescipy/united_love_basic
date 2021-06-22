local linear = {}

function linear.islineCrossing(l_start,l_end,m_start,m_end) -- each vars are table {1.0,2.3, ... } represent a vector.
    -- check if two lines crossing each other.
    if type(l_start) ~= "table" or type(l_end) ~= "table" or type(m_start) ~= "table" or type(m_end) ~= "table" then
        return "type err."
    end

    local p1 = l_start[1]
    local p2 = l_start[2]
    local p3 = l_end[1]
    local p4 = l_end[2]
    local m1 = m_start[1]
    local m2 = m_start[2]
    local m3 = m_end[1]
    local m4 = m_end[2]

    if ((m1 - m3)*(p2 - p4) - (m2 - m4)*(p1 - p3)) ~= 0.0 then
        local x = (-(m1 - m3)*(p1*p4 - p2*p3) + (p1 - p3)*(m1*m4 - m2*m3))/((m1 - m3)*(p2 - p4) - (m2 - m4)*(p1 - p3))
        if p1 <= x and x <= p3 and m1 <= x and x <= m3 then
            return true
        end
    end
    return false
end

function linear.rotate(axis, target, angle) -- angle unit is radian.
    -- return rotated target point. orientation is axis value.
    if type(axis) ~= "table" or type(target) ~= "table" or type(angle) ~= "number" then
        return "type err."
    end

    local p1 = target[1]
    local p2 = target[2]
    local o1 = axis[1]
    local o2 = axis[2]
    local theta = angle

    local radious = math.sqrt((p1 - o1) * (p1 - o1) + (p2 - o2) * (p2 - o2))
    local x = p1 - o1
    local y = p2 - o2
    local polar_P = {radious, linear.toangle(x,y)}

    polar_P[2] = polar_P[2] + theta
    x = math.cos(polar_P[2]) * polar_P[1] + o1
    y = math.sin(polar_P[2]) * polar_P[1] + o2
    return {x,y}
end

function linear.toangle(x, y)
    local tanAngle = 0.0
    if x == 0.0 then
        if y > 0 then
            tanAngle = math.pi / 2
        elseif y < 0 then
            tanAngle = - math.pi / 2
        else
            return "valueErr"
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
return linear