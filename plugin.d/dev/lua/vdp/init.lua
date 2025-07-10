local vdp = {}

function vdp.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. vdp.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function vdp.diffview_sha(sha, file)
    vim.cmd("DiffviewFileHistory " .. file)
    local start = os.clock()
    local found = false
    while (not found) do
        vim.cmd("sleep 50m")
        for i, line in pairs(vim.fn.getline(1, '$')) do
            if string.find(line, "| " .. string.sub(sha,1,8)) then
                vim.cmd("sleep 50m")
                vim.cmd(tostring(i))
                vim.fn.feedkeys("l")
                found = true
                break
            end
        end
        if (os.clock() - start > 0.02) then
            break
        end
    end
    if not found then
        vim.notify("SHA " .. string.sub(sha,1,8) .. " not found in log", 'error',
        {
            title = "diffview sha",
            animate = true,
            render = "compact",
        })
    end
    print("END")
end

return vdp
