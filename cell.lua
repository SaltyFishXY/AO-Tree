-- 创建新进程
local newProcess = ao.spawn(ao.env.Module.Id, {
    Authority = ao.id,
}).receive()
print('send Eval to add handler to the new process: ' .. newProcess.Process)

-- 向新进程发送 Eval 动作，注册 Ping 处理器
ao.send({
    Target = newProcess.Process,
    Action = 'Eval',
    Data = [[
        Handlers.add(
            'ping',
            Handlers.utils.hasMatchingTag('Action', 'Ping'),
            function(msg)
                msg.reply({ Data = 'Pong'})
            end
        )
    ]]
})

-- 在 Eval 后发送 Ping 动作
print('send ping to new process: ' .. newProcess.Process)
ao.send({
    Target = newProcess.Process,
    Action = 'Ping',
})
