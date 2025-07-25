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

local MIN_VISIT_DATE = "2025-05-01"
local MAX_VISIT_DATE = "2025-07-31"

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
  includeLabCaches = true
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
    "gccode", "cache_name", "hidden", "last_publish_date", "attributes_set"
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

table.insert(html, "<h3 style='margin-top: 0px;'>Cachefest Hawaii 2025: Catch the Wave</h3>")
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

--
-- Wave 1: Beach Breakers
--

local pts1 = 0
table.insert(html, "<h4>Wave 1: Beach Breakers</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

local w1_scuba_geocaches_found = 0
local w1_hawaii_caches_found = 0
local w1_hawaii_caches_placed = 0
local w1_events_attended = 0
local w1_old_caches_found = 0

-- Find 1 cache with the Scuba Diving Attribute
-- Find 2 caches with "Hawaii" in the title (may place 1 & find 1 to qualify)
-- Attend 1 GeoEvent
-- Find & Log 1 cache published before 12/31/2003
for _, f in ipairs(finds) do
  if f.type ~= "Lab Cache" and math.floor(f.attributes_set_1 / 16) % 2 == 1 then
    w1_scuba_geocaches_found = w1_scuba_geocaches_found + 1
  end
  if string.find(f.cache_name, "[hH][aA][wW][aA][iI][iI]") then
    w1_hawaii_caches_found = w1_hawaii_caches_found + 1
  end
  if (
    f.type == "Event Cache" or f.type == "Cache In Trash Out Event" or f.type == "Lost and Found Event Cache"
    or f.type == "Mega-Event Cache" or f.type == "Giga-Event Cache" or f.type == "Groundspeak Block Party"
  ) then
    w1_events_attended = w1_events_attended + 1
  end
  if f.type ~= "Lab Cache" and f.last_publish_date <= "2003-12-31" then
    w1_old_caches_found = w1_old_caches_found + 1
  end
end
for _, h in ipairs(hides) do
  if string.find(h.cache_name, "[hH][aA][wW][aA][iI][iI]") then
    w1_hawaii_caches_placed = w1_hawaii_caches_placed + 1
  end
end

if w1_scuba_geocaches_found > 0 then
  table.insert(html, q(
    "check",
    "Find 1 cache with the 'Scuba gear required' attribute.",
    string.format(
      "You've found %d cache(s) with the 'Scuba gear required' attribute.",
      w1_scuba_geocaches_found
    )
  ))
  pts1 = pts1 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 1 cache with the 'Scuba gear required' attribute.",
    "You've found no caches with the 'Scuba gear required' attribute."
  ))
end
if w1_hawaii_caches_found >= 2 or (w1_hawaii_caches_found == 1 and w1_hawaii_caches_placed > 0) then
  table.insert(html, q(
    "check",
    "Find 2 caches with 'Hawaii' in the title (may include up to one owned cache).",
    string.format(
      "You've found %d cache(s) with 'Hawaii' in the title and placed %d cache(s) with 'Hawaii' in the title.",
      w1_hawaii_caches_found, w1_hawaii_caches_placed
    )
  ))
  pts1 = pts1 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 2 caches with 'Hawaii' in the title (may include up to one owned cache).",
    string.format(
      "You've found %d cache(s) with 'Hawaii' in the title and placed %d cache(s) with 'Hawaii' in the title.",
      w1_hawaii_caches_found, w1_hawaii_caches_placed
    )
  ))
end
if w1_events_attended > 0 then
  table.insert(html, q(
    "check",
    "Attend an event.",
    string.format("You've attended %d event(s).", w1_events_attended)
  ))
  pts1 = pts1 + 1
else
  table.insert(html, q(
    "cancel",
    "Attend an event.",
    "You've attended no event(s)."
  ))
end
if w1_old_caches_found > 0 then
  table.insert(html, q(
    "check",
    "Find a cache published on or before 2003-12-31.",
    string.format("You've found %d cache(s) published on or before 2003-12-31.", w1_old_caches_found)
  ))
  pts1 = pts1 + 1
else
  table.insert(html, q(
    "cancel",
    "Find a cache published on or before 2003-12-31.",
    "You've found no caches published on or before 2003-12-31."
  ))
end

table.insert(html, [[ </table> ]])
table.insert(html, string.format([[<p>You've earned <b>%d</b> points in the "Beach Breakers" wave.</p>]], pts1))

--
-- Wave 2: Beach Breakers
--

local pts2 = 0
table.insert(html, "<h4>Wave 2: Mushy Waves</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- Find 1 cache with a D/T >= 3.5/3.5
-- Attain any "00" milestone (anything ending in "00" qualifies)
-- Hide & Publish 1 challenge cache
-- Find one cache not previously found in 2025
-- Find 5 caches with 2 Attributes in common
local w2_high_dt_caches_found = 0
local w2_challenge_caches_placed = 0
for _, f in ipairs(finds) do
  if f.type ~= "Lab Cache" and tonumber(f.difficulty) >= 3.5 and tonumber(f.terrain) >= 3.5 then
    w2_high_dt_caches_found = w2_high_dt_caches_found + 1
  end
end
for _, h in ipairs(hides) do
  if math.floor(h.attributes_set_3 / 64) % 2 == 1 then
    w2_challenge_caches_placed = w2_challenge_caches_placed + 1
  end
end

if w2_high_dt_caches_found > 0 then
  table.insert(html, q(
    "check",
    "Find a cache with a D/T rating at least 3.5/3.5.",
    string.format(
      "You've found %d cache(s) with a D/T rating at least 3.5/3.5.",
      w2_high_dt_caches_found
    )
  ))
  pts2 = pts2 + 1
else
  table.insert(html, q(
    "cancel",
    "Find a cache with a D/T rating at least 3.5/3.5.",
    "You've found no caches with a D/T rating at least 3.5/3.5."
  ))
end

-- Special support for milestones.
local all_finds = PGC.GetFinds(profileId, {
  fields = {},
  order = 'OLDESTFIRST',
  filter = {
    maxVisitDate = MAX_VISIT_DATE,
  },
  includeLabCaches = true
})
for i = #all_finds, 1, -1 do
  if all_finds[i].type == "Lab Cache" then
    if all_finds[i].visitdate > MAX_VISIT_DATE then
      table.remove(all_finds, i)
    end
  end
end
local starting_findcount = #all_finds - #finds
local starting_findcount_bucket = math.floor(starting_findcount / 100)
local ending_findcount_bucket = math.floor(#all_finds / 100)
if starting_findcount_bucket ~= ending_findcount_bucket then
  table.insert(html, q(
    "check",
    "Attain a '00' milestone.",
    string.format(
      "You reached your %d milestone.",
      (starting_findcount_bucket + 1) * 100
    )
  ))
  pts2 = pts2 + 1
else
  table.insert(html, q(
    "cancel",
    "Attain a '00' milestone.",
    string.format(
      "You have %d more caches to find to reach your %d milestone.",
      (starting_findcount_bucket + 1) * 100 - #all_finds, (starting_findcount_bucket + 1) * 100
    )
  ))
end

if w2_challenge_caches_placed > 0 then
  table.insert(html, q(
    "check",
    "Place a Challenge cache.",
    string.format(
      "You've placed %d Challenge cache(s).",
      w2_challenge_caches_placed
    )
  ))
  pts2 = pts2 + 1
else
  table.insert(html, q(
    "cancel",
    "Place a Challenge cache.",
    "You've placed no Challenge caches."
  ))
end

-- Special support for lonely caches.
local lonely_finds = PGC.GetLonelyFinds(profileId, 120, { fallback = "hidden" })
for i = #lonely_finds, 1, -1 do
  if lonely_finds[i].visitdate < MIN_VISIT_DATE or lonely_finds[i].visitdate > MAX_VISIT_DATE or lonely_finds[i].former_visitdate >= "2025-01-01" then
    table.remove(lonely_finds, i)
  end
end

if #lonely_finds > 0 then
  table.insert(html, q(
    "check",
    "Find one cache not previously found in 2025.",
    string.format("You've found %d cache(s) not previously found in 2025.", #lonely_finds)
  ))
  pts2 = pts2 + 1
else
  table.insert(html, q(
    "cancel",
    "Find one cache not previously found in 2025.",
    "You've found no caches not previously found in 2025."
  ))
end

-- Special support for 5-with-2-matching-attributes.
function popcnt(n)
  local cnt = 0
  while n > 0 do
    cnt = cnt + (n % 2)
    n = math.floor(n / 2)
  end
  return cnt
end

local function bitwise_and(a, b)
  if a == nil or b == nil then
    return 0
  end

  local result = 0
  local power = 1
  while a > 0 or b > 0 do
    local bit_a = a % 2
    local bit_b = b % 2
    if bit_a == 1 and bit_b == 1 then
      result = result + power
    end
    a = math.floor(a / 2)
    b = math.floor(b / 2)
    power = power * 2
  end
  return result
end

local function find_valid_subset_1(arr)
  local n = #arr

  for i = 1, n - 4 do
    for j = i + 1, n - 3 do
      for k = j + 1, n - 2 do
        -- Test, here, to see if it's even worth proceeding.
        local total_common_bits = 0
        for _, key in ipairs({"attributes_set_1", "attributes_set_2", "attributes_set_3", "attributes_unset_1", "attributes_unset_2", "attributes_unset_3"}) do
          local and_result = bitwise_and(arr[i][key], bitwise_and(arr[j][key], arr[k][key]))
          total_common_bits = total_common_bits + popcnt(and_result)
        end

        if total_common_bits >= 2 then
          for l = k + 1, n - 1 do
            for m = l + 1, n do
              -- Compute bitwise AND across each attribute separately
              local total_common_bits = 0
              for _, key in ipairs({"attributes_set_1", "attributes_set_2", "attributes_set_3", "attributes_unset_1", "attributes_unset_2", "attributes_unset_3"}) do
                local and_result = bitwise_and(arr[i][key], bitwise_and(arr[j][key], bitwise_and(arr[k][key], bitwise_and(arr[l][key], arr[m][key]))))
                total_common_bits = total_common_bits + popcnt(and_result)
              end

              -- Check if at least two bits are set in total
              if total_common_bits >= 2 then
                return {arr[i], arr[j], arr[k], arr[l], arr[m]}
              end
            end
          end
        end
      end
    end
  end
  return nil
end

local five_w_two_common = find_valid_subset_1(non_lab_finds)
if five_w_two_common then
  table.insert(html, q(
    "check",
    "Find five caches with two attributes in common.",
    string.format(
      "You've found %s, %s, %s, %s, and %s which share two attributes in common.",
      five_w_two_common[1].gccode,
      five_w_two_common[2].gccode,
      five_w_two_common[3].gccode,
      five_w_two_common[4].gccode,
      five_w_two_common[5].gccode
    )
  ))
  pts2 = pts2 + 1
else
  table.insert(html, q(
    "cancel",
    "Find five caches with two attributes in common.",
    "You have not found five caches with two attributes in common."
  ))
end

table.insert(html, [[ </table> ]])
table.insert(html, string.format([[<p>You've earned <b>%d</b> points in the "Mushy Waves" wave.</p>]], pts2))

--
-- Wave 3: Point Breaks
--

local pts3 = 0
table.insert(html, "<h4>Wave 3: Point Breaks</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- Find 7 different cache types
-- Find, Qualify & Claim 5 challenge caches
-- Find 1 cache with >= 50 favorite points
-- Find 1 cache with 15 attributes
-- Find 10 caches with the Boat Required attribute
-- Attend 3 GeoEvents (one each in May/June/July)
local w3_cache_types_found = {}
local w3_challenge_caches_found = 0
local w3_high_fps = 0
local w3_high_attributes = 0
local w3_boat_required = 0
local w3_event_may = 0
local w3_event_jun = 0
local w3_event_jul = 0
for _, f in ipairs(finds) do
  w3_cache_types_found[f.type] = 1
  if f.type ~= "Lab Cache" and math.floor(f.attributes_set_3 / 64) % 2 == 1 then
    w3_challenge_caches_found = w3_challenge_caches_found + 1
  end
  if f.type ~= "Lab Cache" and tonumber(f.favorite_points) >= 50 then
    w3_high_fps = w3_high_fps + 1
  end
  if f.type ~= "Lab Cache" then
    -- Count attributes, but ignore disabled?
    local attributes_cnt = 0
    for _, a in ipairs(
      { f.attributes_set_1, f.attributes_set_2, f.attributes_set_3, f.attributes_unset_1, f.attributes_unset_2, f.attributes_unset_3 }
    ) do
      for i = 1, 32 do
        if a % 2 == 1 then
          attributes_cnt = attributes_cnt + 1
        end
        a = math.floor(a / 2)
      end
    end
    if attributes_cnt >= 15 then
      w3_high_attributes = w3_high_attributes + 1
    end
  end
  if f.type ~= "Lab Cache" and math.floor(f.attributes_set_1 / 8) % 2 == 1 then
    w3_boat_required = w3_boat_required + 1
  end
  if (
    f.type == "Event Cache" or f.type == "Cache In Trash Out Event" or f.type == "Lost and Found Event Cache"
    or f.type == "Mega-Event Cache" or f.type == "Giga-Event Cache" or f.type == "Groundspeak Block Party"
  ) then
    local visitmonth = string.sub(f.visitdate, 6, 7)
    if visitmonth == "05" then
      w3_event_may = w3_event_may + 1
    elseif visitmonth == "06" then
      w3_event_jun = w3_event_jun + 1
    elseif visitmonth == "07" then
      w3_event_jul = w3_event_jul + 1
    end
  end
end

local w3_cache_types_found_count = 0
for _, _ in pairs(w3_cache_types_found) do
  w3_cache_types_found_count = w3_cache_types_found_count + 1
end

if w3_cache_types_found_count >= 7 then
  table.insert(html, q(
    "check",
    "Find 7 cache types.",
    string.format(
      "You've found %d cache type(s).",
      w3_cache_types_found_count
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 7 cache types.",
    string.format(
      "You've found %d cache type(s).",
      w3_cache_types_found_count
    )
  ))
end
if w3_challenge_caches_found >= 5 then
  table.insert(html, q(
    "check",
    "Find 5 Challenge caches.",
    string.format(
      "You've found %d Challenge cache(s).",
      w3_challenge_caches_found
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 5 Challenge caches.",
    string.format(
      "You've found %d Challenge cache(s).",
      w3_challenge_caches_found
    )
  ))
end
if w3_high_fps > 0 then
  table.insert(html, q(
    "check",
    "Find one cache with at least 50 FPs.",
    string.format(
      "You've found %d cache(s) with at least 50 FPs.",
      w3_high_fps
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Find one cache with at least 50 FPs.",
    string.format(
      "You've found %d cache(s) with at least 50 FPs.",
      w3_high_fps
    )
  ))
end
if w3_high_attributes > 0 then
  table.insert(html, q(
    "check",
    "Find one cache with fifteen attributes.",
    string.format(
      "You've found %d cache(s) with fifteen attributes.",
      w3_high_attributes
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Find one cache with fifteen attributes.",
    string.format(
      "You've found %d cache(s) with fifteen attributes.",
      w3_high_attributes
    )
  ))
end
if w3_boat_required >= 10 then
  table.insert(html, q(
    "check",
    "Find 10 caches with the 'Boat required' attribute.",
    string.format(
      "You've found %d cache(s) with the 'Boat required' attribute.",
      w3_boat_required
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 10 caches with the 'Boat required' attribute.",
    string.format(
      "You've found %d cache(s) with the 'Boat required' attribute.",
      w3_boat_required
    )
  ))
end

if w3_event_may > 0 and w3_event_jun > 0 and w3_event_jul > 0 then
  table.insert(html, q(
    "check",
    "Attend an event in May, June, and July.",
    string.format(
      "You attended %d event(s) in May, %d event(s) in June, and %d event(s) in July.",
      w3_event_may, w3_event_jun, w3_event_jul
    )
  ))
  pts3 = pts3 + 1
else
  table.insert(html, q(
    "cancel",
    "Attend an event in May, June, and July.",
    string.format(
      "You attended %d event(s) in May, %d event(s) in June, and %d event(s) in July.",
      w3_event_may, w3_event_jun, w3_event_jul
    )
  ))
end

table.insert(html, [[ </table> ]])
table.insert(html, string.format([[<p>You've earned <b>%d</b> points in the "Point Breaks" wave.</p>]], pts3))

--
-- Wave 4: Double Up Waves
--

local pts4 = 0
table.insert(html, "<h4>Wave 4: Double Up Waves</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- Hide & Publish 3 challenge caches
-- Find 3 caches with 4 attributes in common
-- Find 5 caches with the geocaching.com solution checker
-- Find 1 cache by 10 different cache owners
-- Find 20 cache with May require swimming attribute
-- Find 25 caches with Scenic view attribute
-- Find 10 different cache types
-- Find 25 caches with Recommended for tourist attribute
local w4_geocaching_solution_checker = 0
local w4_cache_owners = {}
local w4_may_require_swimming = 0
local w4_scenic_view = 0
local w4_recommended_tourists = 0
for _, f in ipairs(finds) do
  if f.type ~= "Lab Cache" then
    -- 72
    if math.floor(f.attributes_set_3 / 128) % 2 == 1 then
      w4_geocaching_solution_checker = w4_geocaching_solution_checker + 1
    end
    if f.owner_id and tonumber(f.owner_id) > 0 then
      w4_cache_owners[f.owner_id] = 1
    end
    -- 12
    if math.floor(f.attributes_set_1 / 2048) % 2 == 1 then
      w4_may_require_swimming = w4_may_require_swimming + 1
    end
    -- 8
    if math.floor(f.attributes_set_1 / 128) % 2 == 1 then
      w4_scenic_view = w4_scenic_view + 1
    end
    -- 63
    if math.floor(f.attributes_set_2 / 1073741824) % 2 == 1 then
      w4_recommended_tourists = w4_recommended_tourists + 1
    end
  end
end
local w4_cache_owners_count = 0
for _, _ in pairs(w4_cache_owners) do
  w4_cache_owners_count = w4_cache_owners_count + 1
end

if w2_challenge_caches_placed >= 3 then
  table.insert(html, q(
    "check",
    "Place three Challenge caches.",
    string.format(
      "You've placed %d Challenge cache(s).",
      w2_challenge_caches_placed
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Place three Challenge caches.",
    string.format(
      "You've placed %d Challenge cache(s).",
      w2_challenge_caches_placed
    )
  ))
end

local function find_valid_subset_2(arr)
  local n = #arr

  for i = 1, n - 4 do
    for j = i + 1, n - 3 do
      for k = j + 1, n - 2 do
        -- Compute bitwise AND across each attribute separately
        local total_common_bits = 0
        for _, key in ipairs({"attributes_set_1", "attributes_set_2", "attributes_set_3", "attributes_unset_1", "attributes_unset_2", "attributes_unset_3"}) do
          local and_result = bitwise_and(arr[i][key], bitwise_and(arr[j][key], arr[k][key]))
          total_common_bits = total_common_bits + popcnt(and_result)
        end

        -- Check if at least two bits are set in total
        if total_common_bits >= 4 then
          return {arr[i], arr[j], arr[k]}
        end
      end
    end
  end
  return nil
end

local three_w_four_common = find_valid_subset_2(non_lab_finds)
if three_w_four_common then
  table.insert(html, q(
    "check",
    "Find three caches with four attributes in common.",
    string.format(
      "You've found %s, %s, and %s which share four attributes in common.",
      three_w_four_common[1].gccode,
      three_w_four_common[2].gccode,
      three_w_four_common[3].gccode
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find three caches with four attributes in common.",
    "You have not found three caches with four attributes in common."
  ))
end

if w4_geocaching_solution_checker >= 5 then
  table.insert(html, q(
    "check",
    "Find 5 caches with the 'Geocaching.com solution checker enabled' attribute.",
    string.format(
      "You've found %d caches with the 'Geocaching.com solution checker enabled' attribute.",
      w4_geocaching_solution_checker
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 5 caches with the 'Geocaching.com solution checker enabled' attribute.",
    string.format(
      "You've found %d caches with the 'Geocaching.com solution checker enabled' attribute.",
      w4_geocaching_solution_checker
    )
  ))
end
if w4_cache_owners_count >= 10 then
  table.insert(html, q(
    "check",
    "Find caches hidden by 10 different players.",
    string.format(
      "You've found caches hidden by %d different players.",
      w4_cache_owners_count
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find caches hidden by 10 different players.",
    string.format(
      "You've found caches hidden by %d different players.",
      w4_cache_owners_count
    )
  ))
end
if w4_may_require_swimming >= 20 then
  table.insert(html, q(
    "check",
    "Find 20 caches with the 'May require swimming' attribute.",
    string.format(
      "You've found %d caches with the 'May require swimming' attribute.",
      w4_may_require_swimming
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 20 caches with the 'May require swimming' attribute.",
    string.format(
      "You've found %d caches with the 'May require swimming' attribute.",
      w4_may_require_swimming
    )
  ))
end
if w4_scenic_view >= 25 then
  table.insert(html, q(
    "check",
    "Find 25 caches with the 'Scenic view' attribute.",
    string.format(
      "You've found %d caches with the 'Scenic view' attribute.",
      w4_scenic_view
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 25 caches with the 'Scenic view' attribute.",
    string.format(
      "You've found %d caches with the 'Scenic view' attribute.",
      w4_scenic_view
    )
  ))
end
if w3_cache_types_found_count >= 10 then
  table.insert(html, q(
    "check",
    "Find 10 cache types.",
    string.format(
      "You've found %d cache type(s).",
      w3_cache_types_found_count
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 10 cache types.",
    string.format(
      "You've found %d cache type(s).",
      w3_cache_types_found_count
    )
  ))
end
if w4_recommended_tourists >= 25 then
  table.insert(html, q(
    "check",
    "Find 25 caches with the 'Recommended for tourists' attribute.",
    string.format(
      "You've found %d caches with the 'Recommended for tourists' attribute.",
      w4_recommended_tourists
    )
  ))
  pts4 = pts4 + 1
else
  table.insert(html, q(
    "cancel",
    "Find 25 caches with the 'Recommended for tourists' attribute.",
    string.format(
      "You've found %d caches with the 'Recommended for tourists' attribute.",
      w4_recommended_tourists
    )
  ))
end

table.insert(html, [[ </table> ]])
table.insert(html, string.format([[<p>You've earned <b>%d</b> points in the "Double Up Waves" wave.</p>]], pts4))

html[2] = string.format(
  "Congratulations! You've earned <b>%d</b> points.", pts1 + pts2 + pts3 + pts4
)

return { ok = true, showOk = false, showExampleLog = false, log = nil, html = table.concat(html, "") }
