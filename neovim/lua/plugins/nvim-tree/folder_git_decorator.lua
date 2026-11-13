-- nvim-tree decorator: mark folders that contain changed files, like VS Code.
-- The folder name is colored and a dot is shown on the right. There is no letter.
-- The colors come from the NvimTreeFolder* highlight groups that are set in
-- lua/plugins/nvim-tree/init.lua.

---@class FolderGitDecorator: nvim_tree.api.Decorator
local FolderGit = require("nvim-tree.api").Decorator:extend()

function FolderGit:new()
  self.enabled = true
  self.highlight_range = "name"
  self.icon_placement = "right_align"
end

-- Highest priority first. Each entry is a pattern for the two character git status.
local priorities = {
  { "NvimTreeFolderMerge", { "^U", "U$", "^AA$", "^DD$" } },
  { "NvimTreeFolderDeleted", { "D" } },
  { "NvimTreeFolderDirty", { "M", "T", "^.R", "^R" } },
  { "NvimTreeFolderStaged", { "^A" } },
  { "NvimTreeFolderNew", { "%?%?" } },
}

---Highlight group for a folder, or nil when it has no git status.
---@return string?, boolean? group, ignored
local function status_group(node)
  local status = node.git_status
  if node.type ~= "directory" or not status then
    return nil
  end

  -- Git ignored folder
  if status.file == "!!" then
    return "NvimTreeFolderIgnored", true
  end

  if not status.dir then
    return nil
  end

  local all = {}
  vim.list_extend(all, status.dir.direct or {})
  vim.list_extend(all, status.dir.indirect or {})

  for _, entry in ipairs(priorities) do
    for _, xy in ipairs(all) do
      for _, pattern in ipairs(entry[2]) do
        if xy ~= "!!" and xy:find(pattern) then
          return entry[1], false
        end
      end
    end
  end
  return nil
end

function FolderGit:highlight_group(node)
  return (status_group(node))
end

function FolderGit:icons(node)
  local group, ignored = status_group(node)
  if not group or ignored then
    return nil
  end
  -- Like VS Code, the dot has the color of the name. Errors and warnings win over git.
  if node.diag_severity == 1 then
    group = "NvimTreeDiagnosticErrorFolderHL"
  elseif node.diag_severity == 2 then
    group = "NvimTreeDiagnosticWarnFolderHL"
  end
  return { { str = "●", hl = { group } } }
end

return FolderGit
