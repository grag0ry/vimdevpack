local vdp = {}

vdp.jobs = {}

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


function vdp.termrun(name, cmd, opts, on_exit)
    return vdp.runlive(name, cmd, on_exit)
end

local function make_output_handler(buf)
    local partial = ""
    return function(_, data)
        if not data then return end
        data[1] = partial .. data[1]
        if data[#data] == "" then
            table.remove(data)
            partial = ""
        else
            partial = table.remove(data)
        end
        if #data > 0 then
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                end
            end)
        end
    end
end

local function open_buf_float(name, buf)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local line_count = vim.api.nvim_buf_line_count(buf)
    local width = math.min(120, vim.o.columns - 4)
    local height = math.min(math.max(line_count, 1), math.floor(vim.o.lines * 0.6))
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
    vim.cmd("stopinsert")
    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true })
    end
end

function vdp.runlive(name, cmd, on_exit)
    local progress = create_progress_handle(name)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "log"

    local entry = { name = name, job_id = nil, buf = buf, status = "running" }
    table.insert(vdp.jobs, entry)

    local handler = make_output_handler(buf)

    local ok, job_id = xpcall(function()
        return vim.fn.jobstart(cmd, {
            on_stdout = handler,
            on_stderr = handler,
            on_exit = function(jid, code)
                vim.schedule(function()
                    entry.status = code == 0 and "done" or "failed"
                    entry.job_id = nil
                    local notif = progress.finish(code)
                    if code ~= 0 and not entry.stopped then open_buf_float(name, buf) end
                    if on_exit then on_exit(jid, code, notif) end
                end)
            end,
        })
    end, function(err)
        progress.fail()
        entry.status = "failed"
        return err
    end)

    if not ok then error(job_id) end

    entry.job_id = job_id
    progress.report_progress("in progress")
    progress.start_spinner()

    return job_id, buf
end

function vdp.jobs_picker()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local icons = { running = "●", done = "✓", failed = "✗" }

    local function entry_maker(e)
        return {
            value = e,
            display = string.format("%s  %s", icons[e.status] or "?", e.name),
            ordinal = e.name,
        }
    end

    local function refresh(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        picker:refresh(finders.new_table({ results = vdp.jobs, entry_maker = entry_maker }), { reset_prompt = false })
    end

    pickers.new({}, {
        prompt_title = "VDP Jobs",
        finder = finders.new_table({ results = vdp.jobs, entry_maker = entry_maker }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                if sel then open_buf_float(sel.value.name, sel.value.buf) end
            end)
            map({ "i", "n" }, "<C-x>", function()
                local sel = action_state.get_selected_entry()
                if sel and sel.value.job_id then
                    sel.value.stopped = true
                    vim.fn.jobstop(sel.value.job_id)
                end
                refresh(prompt_bufnr)
            end)
            map({ "i", "n" }, "<C-d>", function()
                local sel = action_state.get_selected_entry()
                if sel then
                    if sel.value.buf and vim.api.nvim_buf_is_valid(sel.value.buf) then
                        vim.api.nvim_buf_delete(sel.value.buf, { force = true })
                    end
                    for i, j in ipairs(vdp.jobs) do
                        if j == sel.value then
                            table.remove(vdp.jobs, i)
                            break
                        end
                    end
                end
                refresh(prompt_bufnr)
            end)
            return true
        end,
    }):find()
end

function vdp.make(args)
    local base = vim.o.makeprg
    if base == "" or base == nil then
        base = "make"
    end

    local escaped = {}
    for _, a in ipairs(args) do
        table.insert(escaped, vim.fn.shellescape(a))
    end

    local name = "make"
    local shell_arg = base
    if #args > 0 then
        name = name .. " " .. table.concat(args, " ")
        shell_arg = base .. " " .. table.concat(escaped, " ")
    end

    return vdp.termrun(name, { "/bin/bash", "-lc", shell_arg })
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
        vdp.runlive(opts.args, { "/bin/bash", "-lc", opts.args })
    end, { nargs = "+", complete = "shellcmd" })
    vim.api.nvim_create_user_command("Jobs", function()
        vdp.jobs_picker()
    end, {})
end

return vdp
