local queue = {}

function queue.removeleft(tables)
    tables[1] = nil
    for i = 2, #tables do
        tables[i-1] = tables[i]
    end
    tables[#tables] = nil
end

function queue.insertleft(tables, data)
    for i = #tables, 1, -1 do
        tables[i+1] = tables[i]
    end
    tables[1] = data
end

return queue