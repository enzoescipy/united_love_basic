local clone = {}

function clone.takeout(tab) -- return all elements in multi-order table.
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

function clone.cloneD1(tab)
  local result = {}
  for i,v in ipairs(tab) do
    table.insert(result, v)
  end
  return result
end

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