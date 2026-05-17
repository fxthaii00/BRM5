-- Target Sizing Module
-- Handles adjustment of NPC target bounds for visibility/testing

local TargetSizing = {}

TargetSizing.originalSizes = {} -- Storage for original sizes to restore them later

-- Adjusts the NPC target bounds
function TargetSizing:applyTargetSizing(model, character, config, npcManager)
    -- Resolve the target part from config
    local root
    if config.TARGET_BOX_PART and character and character:FindFirstChild(config.TARGET_BOX_PART) then
        root = character:FindFirstChild(config.TARGET_BOX_PART)
    else
        root = npcManager and npcManager.getRootPart and npcManager.getRootPart(character) or character:FindFirstChild("HumanoidRootPart")
    end
    if not root then return end

    if not self.originalSizes[model] then
        self.originalSizes[model] = {
            size         = root.Size,
            transparency = root.Transparency,
            color        = root.Color,
            canCollide   = root.CanCollide,
            part         = root,
        }
    end

    if root.Size ~= config.TARGET_BOX_SIZE then
        root.Size = config.TARGET_BOX_SIZE
    end

    local targetTransparency = config.showTargetBox and config.TARGET_BOX_TRANSPARENCY or 1
    if root.Transparency ~= targetTransparency then
        root.Transparency = targetTransparency
    end

    if config.showTargetBox and root.Color ~= config.TARGET_BOX_COLOR then
        root.Color = config.TARGET_BOX_COLOR
    end

    if not root.CanCollide then
        root.CanCollide = true
    end
end

-- Restores target bounds to their normal size
function TargetSizing:restoreOriginalSize(model, npcManager)
    local data = npcManager:getActiveNPCs()[model]
    local saved = self.originalSizes[model]
    if not saved then return end

    local root = saved.part
    if not root then
        local character = data and data.character
        root = character and npcManager.getRootPart(character) or npcManager.getRootPart(model)
    end
    if root then
        root.Size         = saved.size
        root.Transparency = saved.transparency
        root.Color        = saved.color
        root.CanCollide   = saved.canCollide
    end
    self.originalSizes[model] = nil
end

-- Updates target bounds for all NPCs based on config
function TargetSizing:updateAllTargets(npcManager, config)
    if not config.sizingEnabled then
        if next(self.originalSizes) then
            self:cleanup(npcManager)
        end
        return
    end
    for model, data in pairs(npcManager:getActiveNPCs()) do
        if data.root then
            local character = data.character or model
            self:applyTargetSizing(model, character, config, npcManager)
        end
    end
end

-- Cleanup all adjusted target bounds
function TargetSizing:cleanup(npcManager)
    for model, _ in pairs(self.originalSizes) do
        self:restoreOriginalSize(model, npcManager)
    end
end

return TargetSizing
