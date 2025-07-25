local status = { }
local args={...}
conf = args[1].config
if conf.needed == nil then
    conf.needed = 1
else
    conf.needed = tonumber(conf.needed)
end
if conf.countriesneeded == nil then
    conf.countriesneeded = 1
else
    conf.countriesneeded = tonumber(conf.countriesneeded)
end


local attributeDescriptions = {
  [1] = "Dogs allowed",
  [2] = "Access/parking fee",
  [3] = "Climbing gear required",
  [4] = "Boat required",
  [5] = "Scuba gear required",
  [6] = "Kid-friendly",
  [7] = "Takes less than 1 hour",
  [8] = "Scenic view",
  [9] = "Significant hike",
  [10] = "Difficult climbing",
  [11] = "May require wading",
  [12] = "May require swimming",
  [13] = "Available 24/7",
  [14] = "Recommended at night",
  [15] = "Available in winter",
  [17] = "Poison plants",
  [18] = "Dangerous animals",
  [19] = "Ticks",
  [20] = "Abandoned mine nearby",
  [21] = "Cliffs/falling rocks nearby",
  [22] = "Hunting area",
  [23] = "Dangerous area",
  [24] = "Wheelchair-accessible",
  [25] = "Parking available",
  [26] = "Public transit available",
  [27] = "Drinking water nearby",
  [28] = "Restrooms available",
  [29] = "Telephone nearby",
  [30] = "Picnic tables available",
  [31] = "Camping available",
  [32] = "Bikes allowed",
  [33] = "Motorcycles allowed",
  [34] = "Quads allowed",
  [35] = "Off-road vehicles allowed",
  [36] = "Snowmobiles allowed",
  [37] = "Horses allowed",
  [38] = "Campfires allowed",
  [39] = "Thorns",
  [40] = "Stealth required",
  [41] = "Stroller-accessible",
  [42] = "Needs maintenance",
  [43] = "Watch for livestock",
  [44] = "Flashlight required",
  [45] = "Lost and found",
  [46] = "Truck-driver-/RV-accessible",
  [47] = "Field puzzle",
  [48] = "UV light required",
  [49] = "May require snowshoes",
  [50] = "Cross-country skis required",
  [51] = "Special tool required",
  [52] = "Night cache",
  [53] = "Park-and-grab",
  [54] = "In an abandoned structure",
  [55] = "Hike shorter than 1 km",
  [56] = "Hike between 1km-10km",
  [57] = "Hike longer than 10km",
  [58] = "Fuel nearby",
  [59] = "Food nearby",
  [60] = "Wireless beacon required",
  [61] = "Partnership cache",
  [62] = "Seasonal access only",
  [63] = "Recommended for tourists",
  [64] = "Tree-climbing required",
  [65] = "In front yard (with permission)",
  [66] = "Teamwork required",
  [67] = "Part of a GeoTour",
  [69] = "Bonus cache",
  [70] = "Power trail",
  [71] = "Challenge cache",
  [72] = "Geocaching.com solution checker",

  [97] = "No dogs allowed", 
  [102]= "Not recommended for kids",
  [103]= "Takes more than 1 hour",
  [104]= "No scenic view",
  [105]= "Not a significant hike",
  [106]= "No difficult climbing",
  [109]= "Not available 24/7",
  [110]= "Not recommended at night",
  [111]= "Not available in winter",
  [113]= "No poison plants",
  [120]= "Not wheelchair-accessible",
  [121]= "No parking available",
  [123]= "No drinking water available",
  [124]= "No public restrooms nearby",
  [125]= "No telephone nearby",
  [126]= "No picnic tables nearby",
  [127]= "No camping",
  [128]= "No bicycles",
  [129]= "No motorcycles",
  [130]= "No quads",
  [131]= "No off-road vehicles",
  [132]= "No snowmobiles",
  [133]= "No horses",
  [134]= "No campfires",
  [136]= "No stealth required",
  [137]= "Not stroller-accessible", 
  [142]= "Not truck-driver-/RV-accessible",
  [143]= "Not a field puzzle",
  [148]= "Not a night cache",
  [149]= "Not a park-and-grab",
  [150]= "Not in an abandoned structure",
  [151]= "Not a short hike",
  [152]= "Not a medium hike",
  [153]= "Not a long hike",
  [154]= "No fuel nearby",
  [155]= "No food nearby",
  [159]= "Not recommended for tourists",
  [160]= "No tree-climbing required",
  [161]= "Not in a front yard",
  [162]= "No teamwork required"
}



PGC.print("Needed: ", conf.needed, "\n")
PGC.print("Attribute: ", conf.attribute, "\n")
PGC.print("Set/unset: ", conf.setunset, "\n")
profileName = args[1]['profileName']
PGC.print('Got profile name, ', profileName, "\n")
profileId = PGC.ProfileName2Id(profileName)
PGC.print('Converted to id ', profileId, "\n")


function FindAttr(x, atrid)
  x = tonumber(x)
  atrid = atrid - 1
  local r = ""
  for i = 0, atrid do
    r = (x % 2) .. r
    x = (x - (x % 2)) / 2
  end
  if (string.sub(r, 1, 1)) == "0" then
      return false
  else
      return true
  end
end 

function count (list)
    local n = 0
    for i, j in pairs(list) do
        n = n + 1
    end
    return n
end


myFinds = PGC.GetFinds( profileId, { fields = { 'gccode', 'cache_name', 'country', 'attributes_set', 'attributes_unset' } } )

local attribute = tonumber(conf.attribute)

-- Attribute documentation: https://code.google.com/p/geotoad/wiki/FAQ

local att_set
local att_mask
if (conf.setunset == "set") then
    if (attribute <= 32) then
        att_set = "attributes_set_1"
    elseif (attribute <= 64) then
        att_set = "attributes_set_2"
    else
        att_set = "attributes_set_3"
    end
else
    if (attribute <= 32) then
        att_set = "attributes_unset_1"
    elseif (attribute <= 64) then
        att_set = "attributes_unset_2"
    else
        att_set = "attributes_unset_3"
    end
end

local att_num = attribute
while att_num > 32 do
    att_num = att_num - 32
end
-- att_mask = math.pow(2, att_num - 1) -- FIXME: bitwise and

local numdone = 0
local qual = { }
local countries = { }

-- Check which caches are valid for challenge.
-- FIXME: This should be done with a filter to GetFinds.
for i, f in ipairs(myFinds) do
    if (conf.country == nil or conf.country == f['country']) then
--        if (f[att_set] and att_mask) then -- FIXME: bitwise and
        if (FindAttr(f[att_set], att_num)) then
            -- Cache valid for challenge.
            numdone = numdone + 1
            if numdone <= conf.needed then
                table.insert(qual, f['gccode'] .. " " .. f['cache_name'])
            end
            countries[f['country']] = 1
        end
    end
end
if conf.setunset=="unset" then
    conf.attribute=conf.attribute+96
end

PGC.print("Found " .. numdone .. " caches with attribute " .. attributeDescriptions[conf.attribute] .. " (" .. conf.setunset .. ") out of " .. conf.needed .. " needed.\n")

-- Build a log entry.
local ok = false
local log = false
PGC.print("countries " .. count(countries) .. "\n")
if numdone >= conf.needed and count(countries) >= conf.countriesneeded then
    ok = true
    log = "Found " .. numdone .. " caches with attribute " .. attributeDescriptions[conf.attribute] .." out of " .. conf.needed .. " needed, in "
      .. count(countries) .. " countries out of " .. conf.countriesneeded .. " needed.\n"
    log = log .. table.concat(qual, "\n")
else
    html = "Only found " .. numdone .. " caches with attribute " .. attributeDescriptions[conf.attribute] 
      .. " out of " .. conf.needed .. " needed, in " .. count(countries) .. " countries out of " .. conf.countriesneeded .. " needed.\n"
end

return { ok = ok, log = log, html = html }
