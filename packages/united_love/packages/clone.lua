local clone = {}
---# clone.takeout
--- return all elements in multi-order table.
--- ex : {a,b,{c,d,e},{{f},g}} -> {a,b,c,d,e,f,g}
--- @param tab table -- any n-dimentional table can be here
--- @return table collection -- spreded table, 1-dementional
function clone.takeout(tab) 
    local collection = {}
    for i,v in pairs(tab) do
      if type(v) == "table" then
         local subcollection = clone.takeout(v)
       for i,k in pairs(subcollection) do
         table.insert(collection, k)
       end
      else
        table.insert(collection, v)
      end
    end
    return collection
end

---# clone.dictionalize
--- united_love.lua only function.
--- in united_love GameObject, there can be GameObject.folder component, that can include other gbjs.
--- so, it can work like tables, and also can be targeted by clone.takeout-like functions.
--- this function is that function, which takes out all of gbjs inside of gbj.folder 
--- and itself, too.
--- @param mgbj any -- any united_love origined gameobject can be here.
--- @return table collection -- 1d-list of gameobjs.
function clone.dictionalize(mgbj) -- return all gameobj in one gameobj include itself and all of the midle-order gbjs.
  local collection = {}
  table.insert(collection, mgbj)
    for i,cgbj in ipairs(mgbj.folder.gbjstore) do
      if cgbj.folder ~= nil then
         local subcollection = clone.dictionalize(cgbj)
       for p,k in pairs(subcollection) do
         table.insert(collection, k)
       end
      else
        table.insert(collection, cgbj)
      end
    end
  return collection
end

---# clone.clone
--- clonning any nested tables, by recursion.
--- can consume the process resources quite a lot.
--- @param tab any --
--- @return table copy --
function clone.clone(tab)
  if type(tab) == "string" then
    print(tab)
  end
  local copy = {}
	for k, v in pairs(tab) do
		if type(v) == "table" then
			v = clone.clone(v)
		end
		copy[k] = v
	end
	return copy
end

---# clone.cloneD1
--- it can truly copy only the 1d tables.
--- works same as other platforms' shallowcopy.
--- @param tab table -- 1D table
--- @return table result -- 1D table, copied.
function clone.cloneD1(tab)
  local result = {}
  for i,v in ipairs(tab) do
    table.insert(result, v)
  end
  return result
end

---# clone.inspect
--- same as python's print(list).
--- however, if lua prints a table, just "<table:123k29fdjf>" thing will be printed.
--- so I made this func.
--- this function will just print and exited.
---@param t table -- table targeted
function clone.inspect(t)
  local function str_takeout(tab)
    local collection = {}
    table.insert(collection,"{")
    for i,v in pairs(tab) do
      if ((i <= #tab) and (0 <= i) and (tonumber(tostring(i),10) ~= nil ) ) ~= true then
        table.insert(collection, "\n ["..i.."]"..":")
      end
      
      if type(v) == "table" then
        
        local subcollection = str_takeout(v)
        for i,k in pairs(subcollection) do
          table.insert(collection, k)
        end
     else
      if #tab ~= 1 then
        table.insert(collection,",")
      end
      
      table.insert(collection, v)
     end
    end
    table.insert(collection,"}")
    return collection
  end

  print(table.concat(str_takeout(t)))
end

return clone