local clone = {}

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

function clone.dictionalize(mgbj)
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

return clone