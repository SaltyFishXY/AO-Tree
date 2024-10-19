local json = require("json")
local dbAdmin = require("DbAdmin")

local adminUser = "H0OOdNJHHrUNM2n_XZDv7HgMwGUJSlN4RL6xuLEVuic"

-- 模拟数据库，使用 Lua 表来存储树的信息
local trees = {}
local tokenCount = 0  -- 自然代币总数

local function query(stmt)
    local rows = {}
    for row in stmt:nrows() do
        table.insert(rows, row)
    end
    stmt:reset()
    return rows
end

-- 查询所有者的树信息
local function queryTrees(owner)
    -- 在树中查找所有者的树信息
    local tree = trees[owner]
    if not tree then
        return "Error: No tree found for owner " .. owner
    end

    -- 返回树的相关信息
    return json.encode({
        owner = owner,
        height = tree.height,
        leaves = tree.leaves,
        lastUpdated = tree.lastUpdated
    })
end

-- 创建新树
local function createTree(owner, timestamp)
    -- 随机生成树叶形状
    local leaf = "^"
    if math.random() <= 0.05 then
        leaf = "*"
    end

    -- 插入树数据
    trees[owner] = {
        height = 1,       -- 初始高度为 1
        leaves = {leaf},   -- 使用表来存储树叶
        lastUpdated = timestamp
    }

    -- 实时查询状态
    local result = queryTrees(owner)
    print("Creating tree", result)

    return "Tree created for owner: " .. owner
end

-- 增加树的高度（添加新叶子）
-- 增加树的高度（添加新叶子）并计算代币
local function growTree(owner, timestamp)
    local tree = trees[owner]
    if not tree then
        return { success = false, message = "Error: No tree found for owner " .. owner }
    end

    -- 5% 概率改变树叶为 "§"
    local newLeaf = "V"  -- 叶子的默认形状是 "V"
    if math.random() <= 0.05 then
        newLeaf = "§"
    end

    -- 更新树叶和时间戳
    table.insert(tree.leaves, 1, newLeaf)  -- 将新叶添加到树叶列表的顶部
    tree.height = tree.height + 1          -- 树的高度增加
    tree.lastUpdated = timestamp

    -- 如果树达到最大高度，开始计算代币
    if tree.height >= 10 then
        print("Time to harvest!!!")
        
        -- 计算基于树叶类型的自然代币数量
        local treeTokenCount = 0
        for _, leaf in ipairs(tree.leaves) do
            if leaf == "V" then
                treeTokenCount = treeTokenCount + 1  -- 每个 "V" 叶子获取 1 个代币
            elseif leaf == "§" then
                treeTokenCount = treeTokenCount + 10 -- 每个 "§" 叶子获取 10 个代币
            end
        end

        -- 增加总代币数量
        tokenCount = tokenCount + treeTokenCount
        local oldOwner = owner  -- 保存旧所有者信息
        trees[owner] = nil  -- 树达到最大高度后移除
        
        print(" $ Harvest complete! Tokens earned $ ", treeTokenCount)
        
        -- 返回新的树信息和代币数量
        return {
            success = true,
            message = "Tree grown for owner: " .. oldOwner .. ". Tree has been converted to a token!",
            earnedTokens = treeTokenCount,
            totalTokenCount = tokenCount
        }
    end    

    -- 实时查询状态
    local result = queryTrees(owner)
    print("Tree is Growing!", result)
    
    -- 返回当前树的状态
    return {
        success = true,
        message = "Tree is growing for owner: " .. owner,
        tree = result
    }
end


-- 获取树的具现化表示
local function getTreeVisual(owner)
    local tree = trees[owner]
    if not tree then
        return "No tree found for owner " .. owner
    end

    -- 构建树的具现化表示
    local tree_visual = ""
    for i = 1, tree.height do
        if i == 1 then
            tree_visual = tree_visual .. "--" .. "\n"  -- 树干
        else
            tree_visual = tree_visual .. tree.leaves[i - 1] .. "\n"  -- 显示树叶
        end
    end

    return tree_visual
end

-- 获取自然代币的数量
local function getTokenCount()
    return tostring(tokenCount)  -- 返回自然代币的数量
end

-- 降雨功能：消耗20个代币，触发降雨特效并立即成长并收获一棵树
local function rainEffect(owner, timestamp)
    if tokenCount < 20 then
        return { success = false, message = "Not enough tokens for rain effect. Need 20 tokens." }
    end

    -- 消耗代币
    tokenCount = tokenCount - 20
    print("Rain effect triggered! Tokens left: ", tokenCount)

    -- 触发全页面降雨特效
    triggerRainEffect()  -- 这个函数负责在前端触发降雨动画

    -- 立即成长一棵树并进行收获
    local result = growTree(owner, timestamp)
    
    -- 处理返回结果，确保树被成长并收获
    if result.success then
        return {
            success = true,
            message = "Rain effect successful! Tree grown and harvested. " .. result.message,
            tokenCount = tokenCount
        }
    else
        return { success = false, message = "Rain effect failed. " .. result.message }
    end
end

-- 捐赠功能：消耗50个代币，触发爱心降落特效
local function donateEffect(owner)
    if tokenCount < 50 then
        return { success = false, message = "Not enough tokens for donation effect. Need 50 tokens." }
    end

    -- 消耗代币
    tokenCount = tokenCount - 50
    print("Donation effect triggered! Tokens left: ", tokenCount)

    -- 触发全页面爱心降落特效
    triggerDonationEffect()  -- 这个函数负责在前端触发爱心动画

    -- 返回成功消息
    return {
        success = true,
        message = "Donation successful! Love effect triggered.",
        tokenCount = tokenCount
    }
end

-- 处理 WebSocket 消息
function onMessage(ws, message)
    local decodedMessage = json.decode(message)

    if decodedMessage.action == "updateTokenCount" then
        local owner = decodedMessage.owner
        local newTokenCount = decodedMessage.tokenCount

        -- 在数据库或存储中更新用户的代币数量
        updateTokenCountForUser(owner, newTokenCount)

        -- 确认代币数量更新成功后，发送回前端
        ws:send(json.encode({
            type = "tokenUpdate",
            tokenCount = newTokenCount
        }))
    end
end


-- Handlers 绑定部分

Handlers.add(
    "getTokenCount",
    Handlers.utils.hasMatchingTag("Action", "getTokenCount"),
    function (msg)
        if getTokenCount == nil then
            print("Error: getTokenCount 函数未定义")
            Handlers.utils.reply("Error: getTokenCount 未定义")(msg)
        else
            local count = getTokenCount()
            Handlers.utils.reply(count)(msg)  -- 回复自然代币的数量
        end
    end
)

-- 处理种树请求
Handlers.add(
    "initTree",
    Handlers.utils.hasMatchingTag("Action", "initTree"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner
        local timestamp = msg.Timestamp

        local result = createTree(owner, timestamp)
        Handlers.utils.reply(result)(msg)  -- 回复创建树的结果
    end
)

-- 处理树成长请求
Handlers.add(
    "growTree",
    Handlers.utils.hasMatchingTag("Action", "growTree"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = json.decode(msg.Data).owner
        local timestamp = msg.Timestamp

        local result = growTree(owner, msg.Timestamp)
        local tree_visual = getTreeVisual(owner)

        -- 返回树的具现化表示和自然代币数量
        Handlers.utils.reply(tree_visual .. " @ Natural Tokens: " .. getTokenCount())(msg)
    end
)

-- 查询所有者的树状态
Handlers.add(
    "getTree",
    Handlers.utils.hasMatchingTag("Action", "getTree"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner

        local tree_visual = getTreeVisual(owner)
        Handlers.utils.reply(tree_visual)(msg)
    end
)

-- 查询所有者的树信息
Handlers.add(
    "queryTrees",
    Handlers.utils.hasMatchingTag("Action", "queryTrees"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner

        local tree_info = queryTrees(owner)
        Handlers.utils.reply(tree_info)(msg)  -- 回复树的信息
    end
)

-- 获取自然代币的数量


-- 返回模块信息
Handlers.add(
    "Info",
    Handlers.utils.hasMatchingTag("Action", "Info"),
    function (msg)
        local info = [[
            100% Natural！
        ]]
        Handlers.utils.reply(info)(msg)  -- 回复模块信息
    end
)

Handlers.add(
    "rainEffect",
    Handlers.utils.hasMatchingTag("Action", "rainEffect"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner
        local timestamp = msg.Timestamp

        local result = rainEffect(owner, timestamp)
        Handlers.utils.reply(result.message .. " @ Tokens: " .. tokenCount)(msg)  -- 回复消息
    end
)

-- Handlers 绑定捐赠功能
Handlers.add(
    "donateEffect",
    Handlers.utils.hasMatchingTag("Action", "donateEffect"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner

        local result = donateEffect(owner)
        Handlers.utils.reply(result.message .. " @ Tokens: " .. tokenCount)(msg)  -- 回复消息
    end
)