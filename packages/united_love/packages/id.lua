Object = require "packages.united_love.packages.classic"

local Id = Object:extend()

function Id:new(tag)
    if type(tag) == "string" then
        self.tag = tag
    else
        print("type error. in  id:")
        print(type(tag))
        donotusecauseitisforerrorrasing[1]=0
    end
    self.Idlist = {}
    self.IdlistInv = {}
    self.length = 10
    self.count = 0
end

function Id:makeid()
    local Idstr = self.tag .. ":"
    local trial = 0
    while true do
        Idstr = self.tag .. ":"
        for i = 1,self.length do
            local number = math.random(97, 122)
            local char = string.char(number)
            Idstr = Idstr .. char
        end

        if self.IdlistInv == {} or self.IdlistInv[Idstr] == nil then
            break
        end
        trial = trial + 1
    end

    table.insert(self.Idlist, Idstr)
    self.IdlistInv[Idstr] = #self.Idlist
    self.count = self.count + 1

    if trial >= 2 then
        print("id full. check if you can divide id group.")
        print("id count : " .. tostring(self.count))
        print("id length : " .. tostring(self.length))
    end

    return Idstr 
end

function Id:del(idstr)
    local index = self.IdlistInv[idstr]
    table.remove(self.Idlist,index)
    self.IdlistInv = {}
    for i,v in ipairs(self.Idlist) do
        self.IdlistInv[v] = i
    end
end


return Id