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

function vdp.run(name, cmd, opts, on_exit)
    local ctx = { spinner = 1, notification = nil }
    local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

    local function update_spinner(ctx)
        if ctx.spinner == nil then return end
        ctx.spinner = (ctx.spinner + 1) % (#spinner_frames + 1)
        ctx.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[ctx.spinner],
            replace = ctx.notification,
        })
        vim.defer_fn(function()
            update_spinner(ctx)
        end, 150)
    end

    ctx.notification = vim.notify("starting", 'info', {
        title = name,
        icon = spinner_frames[ctx.spinner],
        timeout = false,
        hide_from_history = false,
        render = "compact",
    })

    local on_exit_impl = function(obj)
        ctx.spinner = nil
        if obj.code == 0 then
            ctx.notification = vim.notify("succeed", 'info', {
                hide_from_history = false,
                icon = "",
                replace = ctx.notification,
                animate = true,
                timeout = 3000,
            })
        else
            ctx.notification = vim.notify("failed", 'error', {
                hide_from_history = false,
                icon = "",
                replace = ctx.notification,
                animate = true,
                timeout = 3000,
            })
        end
        if on_exit then on_exit(obj, ctx.notification) end
    end

    local ok, obj = xpcall(
        function()
            return vim.system(cmd, opts, on_exit_impl)
        end,
        function(err)
            ctx.notification = vim.notify("failed", 'error', {
                icon = "",
                replace = ctx.notification,
                animate = true,
                timeout = 3000,
            })
            return err
        end
    )
    if not ok then
        error(obj)
    end

    ctx.notification = vim.notify("in progress. pid " .. tostring(obj.pid), nil, {
        replace = ctx.notification,
    })
    update_spinner(ctx)

    return obj
end

return vdp
