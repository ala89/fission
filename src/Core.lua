local Root = script.Parent
local FEnum = require(Root.Util.FEnum)

local WEAK_KEYS_METATABLE = {__mode = "k"}
local WEAK_VALUES_METATABLE = {__mode = "v"}

local Core = {
    isUpdate = false,
    processorStack = {},

    stackTop = 0,
    order = setmetatable({}, WEAK_VALUES_METATABLE),
    counter = setmetatable({}, WEAK_KEYS_METATABLE)
}

function Core:getCurrentProcessorNode()
    return self.processorStack[#self.processorStack]
end

function Core:pushProcessor(node)
    table.insert(self.processorStack, node)
end

function Core:popProcessor()
    table.remove(self.processorStack)
end

function Core:propagate(root)
    local updateIsNested = self.isUpdate

    self.isUpdate = true

    local function dfs(x, virtual: boolean)
        local oldCounter = self.counter[x]

        if oldCounter == nil then
            self.counter[x] = 0
        end

        if not virtual then
            self.counter[x] += 1
        end

        if oldCounter == nil or (not virtual and oldCounter == 0) then
            for y, type in x.dependentSet do
                dfs(y, virtual or type == FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            end
        end

        if oldCounter == nil then
            self.stackTop += 1
            self.order[self.stackTop] = x
        end
    end

    for y, type in root.dependentSet do
        dfs(y, type == FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
    end

    for _, node in self.order do
        if self.counter[node] == 0 then
            self.counter[node] = nil
        end
    end

    if not updateIsNested then
        while self.stackTop > 0 do
            local node = self.order[self.stackTop]
            self.stackTop -= 1

            if not node then continue end
            if not self.counter[node] then continue end

            self:updateNode(node)
        end

        table.clear(self.order)
        table.clear(self.counter)
        self.isUpdate = false
    end
end

function Core:updateNode(node)
    self.counter[node] = nil
    local hasChanged = node:update()

    -- prune sub-graph
    if not hasChanged then
        local s = {}
        for y, type in node.dependentSet do
            if type ~= FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED then
                table.insert(s, y)
            end
        end

        while #s > 0 do
            local x = table.remove(s)
            if not self.counter[x] then continue end

            self.counter[x] -= 1
            if self.counter[x] == 0 then
                self.counter[x] = nil
                for y, type in x.dependentSet do
                    if type ~= FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED then
                        table.insert(s, y)
                    end
                end
            end
        end
    end
end

function Core:resolveNode(node)
    if not self.counter[node] then
        return node:peek()
    end

    local dependencies = setmetatable({}, WEAK_KEYS_METATABLE)

    local function dfs(x)
        if not self.counter[x] then return end
        if dependencies[x] then return end
        dependencies[x] = true
        for y in x.dependencySet do
            dfs(y)
        end
    end

    dfs(node)

    local stackPointer = self.stackTop - 1
    while stackPointer > 0 do
        local node = self.order[stackPointer]
        stackPointer -= 1

        if not node then continue end
        if not self.counter[node] then continue end
        if not dependencies[node] then continue end

        self:updateNode(node)
    end

    node:update()
    self.counter[node] = nil

    return node:peek()
end

return Core