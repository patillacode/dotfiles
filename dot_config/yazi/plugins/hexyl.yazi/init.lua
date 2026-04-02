-- hexyl.yazi — binary file previewer using hexyl
local M = {}

function M:peek(job)
    local child, err = Command("hexyl")
        :args({ "--border=none", tostring(job.file.url) })
        :stdout(Command.PIPED)
        :stderr(Command.NULL)
        :spawn()
    if not child then
        return ya.err("hexyl: " .. tostring(err))
    end

    local output = child:wait_with_output()
    if not output then return end

    ya.preview_widgets(job, {
        ui.Text.parse(output.stdout):area(job.area),
    })
end

function M:seek(job)
    local h = cx.active.current.hovered
    if h and h.url == job.file.url then
        local step = math.floor(job.units * job.area.h)
        ya.mgr_emit("peek", {
            math.max(0, cx.active.preview.skip + step),
            only_if = tostring(job.file.url),
        })
    end
end

return M
