Object = require "packages.united_love.packages.classic"

local Id = Object:extend()

---# Id
--- create the Id object, that create the <string:tag> + <hash> strings.
--- mathmetically same as hashing function.
--- obsolute algorithm actually...
--- @param tag string -- title string, will ahead in the id-hash-string.
function Id:new(tag)
    if type(tag) == "string" then
        self.tag = tag
    else
        print("type error. in  id:")
        print(type(tag))
        error("Id:new united_love err occured. :: tag type not string!")
    end
    self.Idlist = {}
    self.IdlistInv = {}
    self.length = 10
    self.count = 0
end

---# Id:makeid
--- this method will make string of hash and return it.
--- @return string Idstr -- <string:tag> + <hash> string
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

---# Id:del
--- delete the hashstring. 
--- deleted hash can be made by .makeid method again,
--- while non-deleted one would not.
--- @param idstr string -- <string:tag> + <hash> string
function Id:del(idstr)
    local index = self.IdlistInv[idstr]
    table.remove(self.Idlist,index)
    self.IdlistInv = {}
    for i,v in ipairs(self.Idlist) do
        self.IdlistInv[v] = i
    end
end


return Id