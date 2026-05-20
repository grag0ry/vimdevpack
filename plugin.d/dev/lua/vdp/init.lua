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

local function create_progress_handle(name)
    local ctx = { spinner = 1, notification = nil }
    local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

    local function update_spinner()
        if ctx.spinner == nil then return end
        ctx.spinner = (ctx.spinner + 1) % (#spinner_frames + 1)
        ctx.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[ctx.spinner],
            replace = ctx.notification,
        })
        vim.defer_fn(update_spinner, 150)
    end

    ctx.notification = vim.notify("starting", 'info', {
        title = name,
        icon = spinner_frames[ctx.spinner],
        timeout = false,
        hide_from_history = false,
        render = "compact",
    })

    return {
        start_spinner = function()
            update_spinner()
        end,
        report_progress = function(msg)
             ctx.notification = vim.notify(msg, nil, {
                replace = ctx.notification,
            })
        end,
        finish = function(code)
            ctx.spinner = nil
            local success = (code == 0)
            ctx.notification = vim.notify(success and "succeed" or "failed", success and 'info' or 'error', {
                hide_from_history = false,
                icon = success and "" or "",
                replace = ctx.notification,
                animate = true,
                timeout = 3000,
            })
            return ctx.notification
        end,
        fail = function()
             ctx.spinner = nil
             ctx.notification = vim.notify("failed", 'error', {
                icon = "",
                replace = ctx.notification,
                animate = true,
                timeout = 3000,
            })
        end
    }
end

function vdp.run(name, cmd, opts, on_exit)
    local progress = create_progress_handle(name)

    local on_exit_impl = function(obj)
        vim.schedule(function()
            local notif = progress.finish(obj.code)
            if on_exit then on_exit(obj, notif) end
        end)
    end

    local ok, obj = xpcall(
        function()
            return vim.system(cmd, opts, on_exit_impl)
        end,
        function(err)
            progress.fail()
            return err
        end
    )
    if not ok then
        error(obj)
    end

    progress.report_progress("in progress. pid " .. tostring(obj.pid))
    progress.start_spinner()

    return obj
end

local function show_failed_output(name, stdout, stderr)
    local lines = {}
    for _, src in ipairs({ stdout, stderr }) do
        if src and src ~= "" then
            vim.list_extend(lines, vim.split(src, "\n", { plain = true }))
        end
    end
    while #lines > 0 and lines[#lines] == "" do table.remove(lines) end
    if #lines == 0 then return end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "log"

    local width = math.min(120, vim.o.columns - 4)
    local height = math.min(#lines, math.floor(vim.o.lines * 0.6))
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " " .. name .. ": output ",
        title_pos = "center",
    })
    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true })
    end
end

function vdp.termrun(name, cmd, opts, on_exit)
    opts = opts or {}
    local progress = create_progress_handle(name)

    local ok, proc = xpcall(
        function()
            return vim.system(cmd, { text = true }, function(obj)
                vim.schedule(function()
                    local notif = progress.finish(obj.code)
                    if obj.code ~= 0 then
                        show_failed_output(name, obj.stdout, obj.stderr)
                    end
                    if on_exit then on_exit(obj.pid, obj.code, nil, notif) end
                end)
            end)
        end,
        function(err)
            progress.fail()
            return err
        end
    )
    if not ok then
        error(proc)
    end

    progress.report_progress("in progress. pid " .. tostring(proc.pid))
    progress.start_spinner()

    return proc
end

function vdp.make(args)
    local base = vim.o.makeprg
    if base == "" or base == nil then
        base = "make"
    end

    local arglist = {}
    for _, a in ipairs(args) do
        table.insert(arglist, vim.fn.shellescape(a))
    end
    local argstr = ""
    local name = "make"
    if #arglist > 0 then
        argstr = " " .. table.concat(arglist, " ")
        name = name .. " " .. table.concat(arglist, " ")
    end

    local shell_cmd = "/bin/bash -lc " .. vim.fn.shellescape(base .. argstr)
    return vdp.termrun(name, shell_cmd)
end

function vdp.termrun_cmd(cmd, opts, on_exit)
    if not cmd or #cmd == 0 then
        error("cmd must be a non-empty table")
    end
    return vdp.termrun(cmd[1], cmd, opts, on_exit)
end

function vdp.setup()
    vim.api.nvim_create_user_command("Make", function(opts)
        vdp.make(opts.fargs)
    end, {nargs = "*", complete = "file"})
    vim.api.nvim_create_user_command("Run", function(opts)
        local args = vim.split(opts.args, " ")
        if #args == 0 then
            vim.notify("No command provided", vim.log.levels.ERROR)
            return
        end
        vdp.termrun_cmd(args)
    end, { nargs = "+", complete = "shellcmd" })
    vim.api.nvim_create_user_command("RunDel", function(opts)
        local args = vim.split(opts.args, " ")
        if #args == 0 then
            vim.notify("No command provided", vim.log.levels.ERROR)
            return
        end
        vdp.termrun_cmd(args, { delete_on_success = true })
    end, { nargs = "+", complete = "shellcmd" })
end

return vdp
