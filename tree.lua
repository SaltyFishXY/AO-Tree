local json = require("json")
local sqlite3 = require("lsqlite3")
local dbAdmin = require("DbAdmin")

local adminUser = "H0OOdNJHHrUNM2n_XZDv7HgMwGUJSlN4RL6xuLEVuic"

-- 打开 SQLite 内存数据库
DB = DB or sqlite3.open_memory()
DbAdmin = dbAdmin.new(DB)

-- 创建树表
DB:exec [[
  CREATE TABLE IF NOT EXISTS trees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner TEXT,       -- 树的所有者
    height INT,       -- 树的高度
    leaf TEXT,        -- 树叶的状态 (^ 或 *)
    lastUpdated INT   -- 上次更新的时间戳
  );
]]

-- 执行SQL查询并返回结果
local function query(stmt)
    local rows = {}
    for row in stmt:nrows() do
        table.insert(rows, row)
    end
    stmt:reset()
    return rows
end

-- 检查当前用户是否已有树
local function checkTreeByOwner(owner)
    local stmt = DB:prepare [[
        SELECT * FROM trees WHERE owner = :owner;
    ]]
    stmt:bind_names({ owner = owner })
    local existingTree = query(stmt)[1]
    stmt:finalize()
    return existingTree
end

-- 创建新树
local function createTree(owner, timestamp)
    -- 随机生成树叶形状
    local leaf = "^"
    if math.random() <= 0.05 then
        leaf = "*"
    end

    -- 插入树数据
    local stmt = DB:prepare [[
        INSERT INTO trees (owner, height, leaf, lastUpdated)
        VALUES (:owner, :height, :leaf, :lastUpdated);
    ]]
    stmt:bind_names({
        owner = owner,
        height = 1,      -- 初始高度为 1
        leaf = leaf,
        lastUpdated = timestamp
    })
    local result = stmt:step()
    stmt:finalize()

    if result == sqlite3.DONE then
        return "Tree created for owner: " .. owner
    else
        return "Error creating tree for owner: " .. owner
    end
end

-- 增加树的高度
local function growTree(owner, timestamp)
    local tree = checkTreeByOwner(owner)
    if not tree then
        return "Error: No tree found for owner " .. owner
    end

    -- 5% 概率改变树叶为 "*"
    local leaf = "^"
    if math.random() <= 0.05 then
        leaf = "*"
    end

    -- 更新树的高度和叶子的状态
    local stmt = DB:prepare [[
        UPDATE trees SET height = :height, leaf = :leaf, lastUpdated = :lastUpdated WHERE owner = :owner;
    ]]
    stmt:bind_names({
        height = tree.height + 1,  -- 树的高度 +1
        leaf = leaf,               -- 随机生成的树叶
        lastUpdated = timestamp,
        owner = owner
    })
    stmt:step()
    stmt:finalize()

    return "Tree grown for owner: " .. owner
end

-- 获取树的具现化表示
local function getTreeVisual(owner)
    local tree = checkTreeByOwner(owner)
    if not tree then
        return "No tree found for owner " .. owner
    end

    -- 构建树的具现化表示
    local tree_visual = ""
    for i = 1, tree.height - 1 do
        tree_visual = tree_visual .. "|\n"
    end
    tree_visual = tree_visual .. tree.leaf

    return tree_visual
end

-- 获取所有树的总数
local function getTreeCount()
    local stmt = DB:prepare [[
        SELECT COUNT(*) AS count FROM trees;
    ]]
    local rows = query(stmt)
    stmt:finalize()
    return tostring(rows[1].count)
end

-- Handlers 绑定部分

-- 处理种树请求
Handlers.add(
    "initTree",
    Handlers.utils.hasMatchingTag("Action", "initTree"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner
        local timestamp = msg.Timestamp

        -- 检查是否已有树
        local existingTree = checkTreeByOwner(owner)
        if existingTree then
            Handlers.utils.reply("Tree already exists for owner: " .. owner)(msg)
        else
            local result = createTree(owner, timestamp)
            Handlers.utils.reply(result)(msg)
        end
    end
)

-- 处理树成长请求
Handlers.add(
    "growTree",
    Handlers.utils.hasMatchingTag("Action", "growTree"),
    function (msg)
        local dataJson = json.decode(msg.Data)
        local owner = dataJson.owner
        local timestamp = msg.Timestamp

        local result = growTree(owner, timestamp)
        local tree_visual = getTreeVisual(owner)

        -- 返回树的具现化表示
        Handlers.utils.reply(tree_visual)(msg)
    end
)

-- 获取所有者的树的状态
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

-- 获取树的总数
Handlers.add(
    "getTreeCount",
    Handlers.utils.hasMatchingTag("Action", "getTreeCount"),
    function (msg)
        local count = getTreeCount()
        Handlers.utils.reply(count)(msg)
    end
)

-- 返回模块信息
Handlers.add(
    "Info",
    Handlers.utils.hasMatchingTag("Action", "Info"),
    function (msg)
        local info = [[
            该模块处理树管理，包括种植、成长、获取状态、获取总数等功能。使用SQLite进行存储。

            - initTree：初始化树并确保每个所有者只有一棵树。
            - growTree：每次点击让树成长，并根据一定概率随机改变叶子的形状。
            - getTree：获取某个所有者的树的当前状态。
            - getTreeCount：获取系统中所有树的总数。
        ]]
        Handlers.utils.reply(info)(msg)
    end
)
