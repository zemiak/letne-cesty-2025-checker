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

-- PGC.print produces debug log
--PGC.print('Hides: ', hides, "\n")

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

function testAttribute(find, attribute)
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

--
-- Mestska cesta
--

-- 1. nájdi 5 kešiek s atribútom Public Transportation Nearby -- [26] = "Public transit available"
-- 2. nájdi 3 kešky s atribútom Stroller Accessible -- [41] = "Stroller-accessible"
-- 3. nájdi 5 kešiek s atribútom Bicycles -- [32] = "Bikes allowed"
-- 4. nájdi 2 kešky s atribútom Food Nearby -- [59] = "Food nearby"
-- 5. založ event

table.insert(html, "<h4>Mestska cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

local c1_public_transit_caches_found = 0
local c1_stroller_accessible_caches_found = 0
local c1_bicycles_caches_found = 0
local c1_food_nearby_caches_found = 0
local c1_events_placed = 0

for _, f in ipairs(finds) do
    if testAttribute(f, 26) then
        c1_public_transit_caches_found = c1_public_transit_caches_found + 1
    end

    if testAttribute(f, 41) then
        c1_stroller_accessible_caches_found = c1_stroller_accessible_caches_found + 1
    end

    if testAttribute(f, 32) then
        c1_bicycles_caches_found = c1_bicycles_caches_found + 1
    end

    if testAttribute(f, 59) then
        c1_food_nearby_caches_found = c1_food_nearby_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (h.type == "Event Cache" or h.type == "Cache In Trash Out Event" or h.type == "Lost and Found Event Cache"
        or h.type == "Mega-Event Cache" or h.type == "Giga-Event Cache" or h.type == "Groundspeak Block Party") then
        c1_events_placed = c1_events_placed + 1
    end
end

-- PGC.print produces debug log
PGC.print('Event hides: ', c1_events_placed, "\n")

if c1_public_transit_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Public Transportation Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Public Transportation Nearby' attribute.", c1_public_transit_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Public Transportation Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Public Transportation Nearby' attribute.", c1_public_transit_caches_found)
    ))
end

if c1_stroller_accessible_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 caches with the 'Stroller Accessible' attribute.",
        string.format("You've found %d cache(s) with the 'Stroller Accessible' attribute.", c1_stroller_accessible_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 caches with the 'Stroller Accessible' attribute.",
        string.format("You've found %d cache(s) with the 'Stroller Accessible' attribute.", c1_stroller_accessible_caches_found)
    ))
end

if c1_bicycles_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Bicycles' attribute.",
        string.format("You've found %d cache(s) with the 'Bicycles' attribute.", c1_bicycles_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Bicycles' attribute.",
        string.format("You've found %d cache(s) with the 'Bicycles' attribute.", c1_bicycles_caches_found)
    ))
end

if c1_food_nearby_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 caches with the 'Food Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Food Nearby' attribute.", c1_food_nearby_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 caches with the 'Food Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Food Nearby' attribute.", c1_food_nearby_caches_found)
    ))
end

if c1_events_placed >= 1 then
    table.insert(html, q(
        "check",
        "Place an event cache.",
        string.format("You've placed %d event(s).", c1_events_placed)
    ))
else
    table.insert(html, q(
        "cancel",
        "Place an event cache.",
        string.format("You've placed %d event(s).", c1_events_placed)
    ))
end

table.insert(html, [[ </table> ]])

--
-- Lesna cesta
--

table.insert(html, "<h4>Lesna cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- 1. nájdi 5 earth kešiek -- Earthcache
-- 2. nájdi 3 kešky s atribútom -- [63] = "Recommended for tourists"
-- 3. nájdi 5 kešiek s atribútom -- [8] = "Scenic view"
-- 4. nájdi 2 kešky s atribútom -- [57] = "Hike longer than 10km"
-- 5. založ fyzickú kešku

local c3_earth_caches_found = 0
local c3_tourist_caches_found = 0
local c3_scenic_caches_found = 0
local c3_hike_caches_found = 0
local c3_physical_cache_created = 0

for _, f in ipairs(finds) do
    if f.type == "Earthcache" then
        c3_earth_caches_found = c3_earth_caches_found + 1
    end

    if testAttribute(f, 63) then
        c3_tourist_caches_found = c3_tourist_caches_found + 1
    end

    if testAttribute(f, 8) then
        c3_scenic_caches_found = c3_scenic_caches_found + 1
    end

    if testAttribute(f, 57) then
        c3_hike_caches_found = c3_hike_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (h.type == "Traditional Cache" or h.type == "Multi-cache" or h.type == "Unknown Cache"
        or h.type == "Letterbox Hybrid" or h.type == "Wherigo Cache" or h.type == "Project APE Cache") then
        c3_physical_cache_created = c3_physical_cache_created + 1
    end
end

-- PGC.print produces debug log
PGC.print('Physical hides: ', c3_physical_cache_created, "\n")

if c3_earth_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Earth caches",
        string.format("You've found %d Earth caches(s)", c3_earth_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Earth caches",
        string.format("You've found %d Earth caches(s)", c3_earth_caches_found)
    ))
end

if c3_tourist_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 caches with the 'Recommended for Tourists' attribute.",
        string.format("You've found %d cache(s) with the 'Recommended for Tourists' attribute.", c3_tourist_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 caches with the 'Recommended for Tourists' attribute.",
        string.format("You've found %d cache(s) with the 'Recommended for Tourists' attribute.", c3_tourist_caches_found)
    ))
end

if c3_scenic_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Scenic View' attribute.",
        string.format("You've found %d cache(s) with the 'Scenic View' attribute.", c3_scenic_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Scenic View' attribute.",
        string.format("You've found %d cache(s) with the 'Scenic View' attribute.", c3_scenic_caches_found)
    ))
end

if c3_hike_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 caches with the 'Hike longer than 10km' attribute.",
        string.format("You've found %d cache(s) with the 'Hike longer than 10km' attribute.", c3_hike_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 caches with the 'Hike longer than 10km' attribute.",
        string.format("You've found %d cache(s) with the 'Hike longer than 10km' attribute.", c3_hike_caches_found)
    ))
end

if c3_physical_cache_created >=1 then
    table.insert(html, q(
        "check",
        "Create a physical cache.",
        string.format("You've placed %d physical caches", c3_physical_cache_created)
    ))
else
    table.insert(html, q(
        "cancel",
        "Create a physical cache.",
        string.format("You've placed %d physical caches", c3_physical_cache_created)
    ))
end

table.insert(html, [[ </table> ]])

--
-- Hadankova cesta
--

table.insert(html, "<h4>Hadankova cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- 1. nájdi 5 mystery kešiek bez atribútu Challenge Cache -- [71] = "Challenge cache"
-- 2. nájdi 3 challenge kešky, ktoré spĺňaš -- [71] = "Challenge cache"
-- 3. nájdi 5 multi kešiek -- Multi-cache
-- 4. nájdi 2 kešky typu Whereigo alebo Letterbox -- Wherigo Cache, Letterbox Hybrid
-- 5. založ mystery kešku -- Unknown Cache

local c2_mystery_caches_found = 0
local c2_challenge_caches_found = 0
local c2_multi_caches_found = 0
local c2_whereigo_letterbox_caches_found = 0
local c2_mystery_hides = 0

for _, f in ipairs(finds) do
    if ((not testAttribute(f, 71)) and f.type == "Unknown Cache") then
        c2_mystery_caches_found = c2_mystery_caches_found + 1
    end

    if testAttribute(f, 71) then
        c2_challenge_caches_found = c2_challenge_caches_found + 1
    end

    if f.type == "Multi-cache" then
        c2_multi_caches_found = c2_multi_caches_found + 1
    end

    if (f.type == "Wherigo Cache" or f.type == "Letterbox Hybrid") then
        c2_whereigo_letterbox_caches_found = c2_whereigo_letterbox_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (h.type == "Unknown Cache") then
        c2_mystery_hides = c2_mystery_hides + 1
    end
end

-- PGC.print produces debug log
PGC.print('Mystery hides: ', c2_mystery_hides, "\n")

if c2_mystery_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Mystery Caches, not Challenges.",
        string.format("You've found %d Mystery Caches, not Challenges", c2_mystery_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Mystery Caches, not Challenges.",
        string.format("You've found %d Mystery Caches, not Challenges", c2_mystery_caches_found)
    ))
end

if c2_challenge_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 Challenge Caches that you qualify for.",
        string.format("You've found %d Challenge Caches that you qualify for", c2_challenge_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 Challenge Caches that you qualify for.",
        string.format("You've found %d Challenge Caches that you qualify for", c2_challenge_caches_found)
    ))
end

if c2_multi_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Multi Caches.",
        string.format("You've found %d Multi Caches", c2_multi_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Multi Caches.",
        string.format("You've found %d Multi Caches", c2_multi_caches_found)
    ))
end

if c2_whereigo_letterbox_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 Whereigo or Letterbox Caches.",
        string.format("You've found %d Whereigo or Letterbox Caches", c2_whereigo_letterbox_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 Whereigo or Letterbox Caches.",
        string.format("You've found %d Whereigo or Letterbox Caches", c2_whereigo_letterbox_caches_found)
    ))
end

if c2_mystery_hides >= 1 then
    table.insert(html, q(
        "check",
        "Place a Mystery Cache.",
        string.format("You've placed %d Mystery Caches", c2_mystery_hides)
    ))
else
    table.insert(html, q(
        "cancel",
        "Place a Mystery Cache.",
        string.format("You've placed %d Mystery Caches", c2_mystery_hides)
    ))
end

table.insert(html, [[ </table> ]])

return { ok = true, showOk = false, showExampleLog = false, log = nil, html = table.concat(html, "") }
