local args = {...}
local conf = args[1].config
local profileName = args[1].profileName
local profileId = args[1].profileId
local gccode = args[1].gccode -- gccode from the tag
-- PGC.print produces debug log
PGC.print('Got profile name, ', profileName, "\n")

function printf(fmt, ...)
    PGC.print(string.format(fmt, ...))
end

local MIN_VISIT_DATE = "2025-07-01"
local MAX_VISIT_DATE = "2025-08-31"

--[[
-- Get data for as few fields as possible to reduce memory usage. A full list of fields can be found at http://project-gc.com/doxygen/lua-sandbox/classPGC__LUA__Sandbox.html#a8b8f58ee20469917a29dc7a7f751d9ea
-- We are injecting the conf.filter variable straight into GetFinds here. This adds automatic dynamic to the checker script
--]]
--[[
-- Get data for as few fields as possible to reduce memory usage. A full list of fields can be found at http://project-gc.com/doxygen/lua-sandbox/classPGC__LUA__Sandbox.html#a8b8f58ee20469917a29dc7a7f751d9ea
-- We are injecting the conf.filter variable straight into GetFinds here. This adds automatic dynamic to the checker script
--]]
local finds = PGC.GetFinds(profileId, {
    fields = {
        "gccode",
        "type", "size", "cache_name",
        "visitdate", "hidden", "last_publish_date",
        "difficulty", "terrain",
        "country", "region", "county",
        "attributes_set", "favorite_points", "owner_id",
    },

    order = 'OLDESTFIRST',

    filter = {
        minVisitDate = MIN_VISIT_DATE,
        maxVisitDate = MAX_VISIT_DATE,
    },

    includeLabCaches = false
})

-- Manually filter Lab Caches.
for i = #finds, 1, -1 do
  if finds[i].type == "Lab Cache" then
    if finds[i].visitdate < MIN_VISIT_DATE or finds[i].visitdate > MAX_VISIT_DATE then
      table.remove(finds, i)
    end
  end
end

-- Set up array of non-AL finds.
local non_lab_finds = {}
for i = 1, #finds do
  if finds[i].type ~= "Lab Cache" then
    table.insert(non_lab_finds, finds[i])
  end
end

printf("Found %d acceptable finds.\n", #finds)

local hides = PGC.GetHides(profileId, {
  fields = {
    "gccode", "cache_name", "hidden", "last_publish_date", "attributes_set", "type"
  }
})

-- Manually filter.
for i = #hides, 1, -1 do
  if (
    (hides[i].hidden < MIN_VISIT_DATE or hides[i].hidden > MAX_VISIT_DATE)
    and (hides[i].last_publish_date < MIN_VISIT_DATE or hides[i].last_publish_date > MAX_VISIT_DATE)
  ) then
    table.remove(hides, i)
  end
end

--[[
-- Do calculations
--]]

local html = {}

table.insert(html, "<h3 style='margin-top: 0px;'>Letné cesty 2025</h3>")
table.insert(html, "<p>[PLACEHOLDER]</p>") -- "Congratulations! You've earned ... points."

-- This utility function generates a row.
function q(a, b, c, d)
  if d == nil then d = "" end
  return string.format(
    [[
      <tr>
  	    <td style="padding: 8px; padding-top: 6px; border: 1px solid black; text-align: center; vertical-align: top;">
  	      <img src="https://cdn2.project-gc.com/images/%s16.png" />
  	    </td>
        <td style="padding: 8px; padding-top: 6px; width: 100%%; border: 1px solid black;">
  	      <p><strong>%s</strong></p>
          <p style="margin-bottom: 0px;">%s</p>
          %s
        </td>
      </tr>
    ]],
    a, b, c, d
  )
end

function hasAttribute(find, attribute)
    if (attribute <= 32) then
        att_set = "attributes_set_1"
    elseif (attribute <= 64) then
        att_set = "attributes_set_2"
    else
        att_set = "attributes_set_3"
    end

    local att_num = attribute
    while att_num > 32 do
        att_num = att_num - 32
    end

    x = tonumber(find[att_set])
    att_num = att_num - 1
    local r = ""
    for i = 0, att_num do
        r = (x % 2) .. r
        x = (x - (x % 2)) / 2
    end
    if (string.sub(r, 1, 1)) == "0" then
        return false
    else
        return true
    end
end

--- mestska.lua
--- lesna.lua
--- hadankova.lua


return { ok = true, showOk = false, showExampleLog = false, log = nil, html = table.concat(html, "") }
