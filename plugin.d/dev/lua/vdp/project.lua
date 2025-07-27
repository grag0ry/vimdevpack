local prj = {}

function prj.error(msg)
    vim.notify(msg, 'error', {
        title = "VDP project",
        animate = true,
        render = "compact",
    })
end

function prj.warn(msg)
    vim.notify(msg, 'warn', {
        title = "VDP project",
        animate = true,
        render = "compact",
    })
end

function prj.info(msg)
    vim.notify(msg, 'info', {
        title = "VDP project",
        animate = true,
        render = "compact",
    })
end

function prj.cb_buf_switch()
    if vim.b.VDPProject ~= nil then
        if vim.b.VDPProjectCD ~= nil then
            vim.cmd('lcd ' .. vim.fn.fnameescape(vim.b.VDPProjectCD))
        end
        if vim.b.VDPProjectSubIdx ~= nil then
            local cb = prj.subdir[vim.b.VDPProjectSubIdx].switch_cb
            if cb then cb() end
        end
        if prj.in_switch_cb then prj.in_switch_cb() end
    else
        if prj.out_switch_cb then prj.out_switch_cb() end
    end
end

function prj.issubdir(path, dir)
    return string.sub(path, 0, string.len(dir)) == dir
end

function prj.cb_buf_enter(args)
    local bn = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(bn)
    if prj.issubdir(path, prj.root) then
        vim.b.VDPProject = prj.name
        vim.b.VDPProjectRoot = prj.root
        if prj.auto_cd then
            vim.b.VDPProjectCD = prj.root
        end
        for i,sub in ipairs(prj.subdir) do
            if prj.issubdir(path, sub.path) then
                vim.b.VDPProjectSubIdx = i
                if sub.auto_cd then vim.b.VDPProjectCD = sub.path end
                if sub.enter_cb then sub.enter_cb() end
                break
            end
        end
        if prj.in_enter_cb then prj.in_enter_cb(path) end
    else
        if prj.out_ro then
            vim.cmd('set ro')
        end
        if prj.out_enter_cb then prj.out_enter_cb(path) end
    end
end

function prj.setup(config)
    if config.name == nil then
        return prj.error("project name is nil")
    end
    prj.name = tostring(config.name)
    if prj.root ~= nil then
        return prj.error("cannot configure project twice")
    end
    prj.root = vim.fn.fnamemodify(config.root, ":p")
    if vim.fn.isdirectory(prj.root) == 0 then
        return prj.error(prj.root .. ": no such directory")
    end
    if string.sub(prj.root, -1) ~= vim.g.PathSeparator then
        prj.root = prj.root .. vim.g.PathSeparator
    end

    prj.out_ro = config.out_ro
    prj.out_enter_cb = config.out_enter_cb
    prj.out_switch_cb = config.out_switch_cb
    prj.in_enter_cb = config.in_enter_cb
    prj.in_switch_cb = config.in_switch_cb
    prj.auto_cd = config.auto_cd

    prj.subdir = {}
    if config.subdir then
        for p,c in pairs(config.subdir) do
            local path = vim.fn.fnamemodify(prj.root .. p, ":p")
            if string.sub(path, -1) ~= vim.g.PathSeparator then
                path = path .. vim.g.PathSeparator
            end
            prj.subdir[#prj.subdir+1] = {
                path = path,
                enter_cb = c.enter_cb,
                switch_cb = c.switch_cb,
                auto_cd = c.auto_cd,
            }
        end
        table.sort(prj.subdir, function(a,b) return string.len(b.path) < string.len(a.path) end)
    end

    local augrp = vim.api.nvim_create_augroup('vdp.project', { clear = true })
    vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
        pattern = {"*"},
        group = augrp,
        callback = prj.cb_buf_enter,
    })
    vim.api.nvim_create_autocmd({"BufEnter"}, {
        pattern  = {"*"},
        group = augrp,
        callback = prj.cb_buf_switch,
    })

    if config.setup_cb then config.setup_cb() end
    prj.info(prj.name .. " loaded")
end

return prj
