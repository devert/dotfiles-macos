-- ============================================================================
-- Layouts
-- ============================================================================

-- Named pane layouts. Each one is an action named "layout_<key>" and titled
-- "Layout: <title>" in the command palette. It splits the focused pane in the
-- current tab: that pane becomes the first "pane" in the layout, and the new
-- panes start in its directory. A tree node is either "pane" or a split:
-- { "h" or "v", ratio of the first side, first, second }.
-- "h" puts first on the left, "v" puts first on top.
local layouts = {
  left_right_stack = {
    title = "Left Pane and Right Stack",
    tree  = { "h", 0.5, "pane", { "v", 0.5, "pane", "pane" } },
  },
}

-- ============================================================================
-- Building layouts
-- ============================================================================

local function focused_cwd(ctx)
  if ctx.block_id == nil then return nil end
  local p = rex.block.call("com.superlogical.terminal", "process",
    { block_id = ctx.block_id })
  return p and p.foreground and p.foreground.cwd
end

local function build_layout(node, cwd)
  if node == "pane" then
    return rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { cwd = cwd },
    }
  end
  local split = node[1] == "h" and rex.layout.horizontal or rex.layout.vertical
  return split(node[2], build_layout(node[3], cwd), build_layout(node[4], cwd))
end

-- Splits block_id so that it becomes the first "pane" of node. The second
-- side of each split is created as new panes.
local function apply_layout(node, block_id, cwd)
  if node == "pane" then return end
  local _, err = rex.session.new_split{
    anchor_id = block_id,
    direction = node[1] == "h" and "horizontal" or "vertical",
    side      = "after",
    ratio     = node[2],
    layout    = build_layout(node[4], cwd),
  }
  if err ~= nil then error(err, 0) end
  apply_layout(node[3], block_id, cwd)
end

-- ============================================================================
-- Checking the current tab
-- ============================================================================

-- True when a window's layout node has the same shape as a tree node.
-- Ratios are not compared, so a resized layout still matches.
local function same_shape(node, tree)
  if tree == "pane" then return node.block_id ~= nil end
  local s = node.split
  if s == nil then return false end
  local dir = tree[1] == "h" and "horizontal" or "vertical"
  return s.direction == dir
    and same_shape(s.before, tree[3])
    and same_shape(s.after, tree[4])
end

local function contains_block(node, block_id)
  if node.block_id ~= nil then return node.block_id == block_id end
  return node.split ~= nil
    and (contains_block(node.split.before, block_id)
      or contains_block(node.split.after, block_id))
end

-- True when the tiled panes of the tab that holds block_id already have the
-- shape of tree.
local function tab_has_layout(block_id, tree)
  local view, err = rex.session.view{}
  if err ~= nil then error(err, 0) end
  for _, window in ipairs(view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      if layer.kind == "tiled" and layer.layout ~= nil
        and contains_block(layer.layout, block_id) then
        return same_shape(layer.layout, tree)
      end
    end
  end
  return false
end

-- ============================================================================
-- Actions
-- ============================================================================

for key, layout in pairs(layouts) do
  rex.action({
    name  = "layout_" .. key,
    title = "Layout: " .. layout.title,
    run   = function(ctx)
      if ctx.block_id == nil then error("no focused pane", 0) end
      if tab_has_layout(ctx.block_id, layout.tree) then return end
      apply_layout(layout.tree, ctx.block_id, focused_cwd(ctx))
    end,
  })
end
