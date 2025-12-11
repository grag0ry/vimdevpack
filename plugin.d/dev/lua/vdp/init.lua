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

function vdp.termrun(name, cmd, on_exit, opts)
    opts = opts or {}
    local progress = create_progress_handle(name)
    local bufid

    local on_exit_impl = function(job_id, code, event)
        vim.schedule(function()
            local notif = progress.finish(code)
            if opts.delete_on_success and code == 0 and bufid and vim.api.nvim_buf_is_valid(bufid) then
                vim.api.nvim_buf_delete(bufid, { force = true })
            end
            if on_exit then on_exit(job_id, code, event, notif) end
        end)
    end

    local ok, job_id = xpcall(
        function()
            local current = vim.api.nvim_get_current_buf()
            bufid = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_current_buf(bufid)
            local result = vim.fn.jobstart(cmd, { term = true, on_exit = on_exit_impl })
            vim.api.nvim_set_current_buf(current)
            return result
        end,
        function(err)
            progress.fail()
            return err
        end
    )
    if not ok then
        error(job_id)
    end

    progress.report_progress("in progress")
    progress.start_spinner()

    return job_id
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
    return vdp.termrun(name, shell_cmd, nil)
end

function vdp.termrun_cmd(cmd, on_exit, opts)
    if not cmd or #cmd == 0 then
        error("cmd must be a non-empty table")
    end
    return vdp.termrun(cmd[1], cmd, on_exit, opts)
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
        vdp.termrun_cmd(args, nil, { delete_on_success = true })
    end, { nargs = "+", complete = "shellcmd" })
end

return vdp
