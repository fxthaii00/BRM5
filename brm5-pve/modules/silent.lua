-- Target Sizing Module
-- Handles adjustment of NPC target bounds for visibility/testing

local TargetSizing = {}

TargetSizing.originalSizes = {} -- Storage for original sizes to restore them later

-- Adjusts the NPC target bounds
function TargetSizing:applyTargetSizing(model, root, config)
    -- Save original values only once
    if not self.originalSizes[model] then
        self.originalSizes[model] = {
            size         = root.Size,
            transparency = root.Transparency,
            color        = root.Color,
            canCollide   = root.CanCollide,
        }
    end

    -- Always re-apply (handles live config changes)
    root.Size = config.TARGET_BOX_SIZE

    local targetTransparency = config.showTargetBox and config.TARGET_BOX_TRANSPARENCY or 1
    root.Transparency = targetTransparency

    if config.showTargetBox then
        root.Color = config.TARGET_BOX_COLOR
    end

    root.CanCollide = true
end

-- Restores target bounds to their normal size
function TargetSizing:restoreOriginalSize(model, npcManager)
    local data = npcManager:getActiveNPCs()[model]
    local saved = self.originalSizes[model]
    if not saved then return end

    local root = data and data.root
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
    if not config.sizingEnabled and not config.showTargetBox then
        if next(self.originalSizes) then
            self:cleanup(npcManager)
        end
        return
    end
    for model, data in pairs(npcManager:getActiveNPCs()) do
        if data.root then
            self:applyTargetSizing(model, data.root, config)
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
