mg = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/villages_init.lua")

local ENABLE_SNOW = false

local DMAX = 20
local AREA_SIZE = 80

dofile(minetest.get_modpath(minetest.get_current_modname()).."/nodes.lua")
c_air  = minetest.get_content_id("air")
c_grass  = minetest.get_content_id("default:dirt_with_grass")
c_dry_grass  = minetest.get_content_id("mg:dirt_with_dry_grass")
c_dirt_snow  = minetest.get_content_id("default:dirt_with_snow")
c_snow  = minetest.get_content_id("default:snow")
c_sapling  = minetest.get_content_id("default:sapling")
c_tree  = minetest.get_content_id("default:tree")
c_leaves  = minetest.get_content_id("default:leaves")
c_junglesapling  = minetest.get_content_id("default:junglesapling")
c_jungletree  = minetest.get_content_id("default:jungletree")
c_jungleleaves  = minetest.get_content_id("default:jungleleaves")
c_savannasapling  = minetest.get_content_id("mg:savannasapling")
c_savannatree = minetest.get_content_id("mg:savannatree")
c_savannaleaves  = minetest.get_content_id("mg:savannaleaves")
c_pinesapling  = minetest.get_content_id("mg:pinesapling")
c_pinetree = minetest.get_content_id("mg:pinetree")
c_pineleaves  = minetest.get_content_id("mg:pineleaves")
c_dirt  = minetest.get_content_id("default:dirt")
c_stone  = minetest.get_content_id("default:stone")
c_water  = minetest.get_content_id("default:water_source")
c_ice  = minetest.get_content_id("default:ice")
c_sand  = minetest.get_content_id("default:sand")
c_sandstone  = minetest.get_content_id("default:sandstone")
c_desert_sand  = minetest.get_content_id("default:desert_sand")
c_desert_stone  = minetest.get_content_id("default:desert_stone")
c_snowblock  = minetest.get_content_id("default:snowblock")
c_cactus  = minetest.get_content_id("default:cactus")
c_grass_1  = minetest.get_content_id("default:grass_1")
c_grass_2  = minetest.get_content_id("default:grass_2")
c_grass_3  = minetest.get_content_id("default:grass_3")
c_grass_4  = minetest.get_content_id("default:grass_4")
c_grass_5  = minetest.get_content_id("default:grass_5")
c_grasses = {c_grass_1, c_grass_2, c_grass_3, c_grass_4, c_grass_5}
c_jungle_grass  = minetest.get_content_id("default:junglegrass")
c_dry_shrub  = minetest.get_content_id("default:dry_shrub")
c_papyrus  = minetest.get_content_id("default:papyrus")
c_gravel   = minetest.get_content_id("default:gravel" )

minetest.register_on_mapgen_init(function(mgparams)
		minetest.set_mapgen_params({mgname = "singlenode", flags = "nolight"})
end)

local cache = {}

local function cliff(x, n)
	return 0.2*x*x - x + n*x - n*n*x*x - 0.01 * math.abs(x*x*x) + math.abs(x)*100*n*n*n*n
end

local function get_vn(x, z, noise, village)
	local vx, vz, vs = village.vx, village.vz, village.vs
	return (noise - 2) * 20 +
		(40 / (vs * vs)) * ((x - vx) * (x - vx) + (z - vz) * (z - vz))
end

local function get_base_surface_at_point(x, z, vnoise, villages, ni, noise1, noise2, noise3, noise4)
	local index = 65536*x+z
	if cache[index] ~= nil then return cache[index] end
	cache[index] = 25*noise1[ni]+noise2[ni]*noise3[ni]/3
	if noise4[ni] > 0.8 then
		cache[index] = cliff(cache[index], noise4[ni]-0.8)
	end
	local s = 0
	local t = 0
	local noise = vnoise[ni]
	for _, village in ipairs(villages) do
		local vn = get_vn(x, z, noise, village)
		if vn < 40 then
			cache[index] = village.vh
			return village.vh
		elseif vn < 200 then
			s = s + ((cache[index] * (vn - 40) + village.vh * (200 - vn)) / 160) / (vn - 40)
			t = t + 1 / (vn - 40)
		end
	end
	if t > 0 then
		cache[index] = s / t
	end
	return cache[index]
end

local function surface_at_point(x, z, ...)
	return get_base_surface_at_point(x, z, unpack({...}))
end

local SMOOTHED = AREA_SIZE+2*DMAX
local HSMOOTHED = AREA_SIZE+DMAX
local INSIDE = AREA_SIZE-DMAX

local function smooth(x, z, ...)
	local s=0
	local w=0
	for xi=-DMAX, DMAX do
	for zi=-DMAX, DMAX do
		local d2=xi*xi+zi*zi
		if d2<DMAX*DMAX then
			local w1 = 1-d2/(DMAX*DMAX)
			local w2 = 15/16*w1*w1
			w = w+w2
			s=s+w2*surface_at_point(x+xi, z+zi, unpack({...}))
		end
	end
	end
	return s/w
end

function inside_village(x, z, village, vnoise)
	return get_vn(x, z, vnoise:get2d({x = x, y = z}), village) <= 40
end

minetest.register_on_mapgen_init(function(mgparams)
	wseed = math.floor(mgparams.seed/10000000000)
end)
function get_bseed(minp)
	return wseed + math.floor(5*minp.x/47) + math.floor(873*minp.z/91)
end

function get_bseed2(minp)
	return wseed + math.floor(87*minp.x/47) + math.floor(73*minp.z/91) + math.floor(31*minp.y/12)
end

c_ignore = minetest.get_content_id("ignore")
c_water = minetest.get_content_id("default:water_source")

local function add_leaves(data, vi, c_leaves, c_snow)
	if data[vi]==c_air or data[vi]==c_ignore or data[vi] == c_snow then
		data[vi] = c_leaves
	end
end

function add_tree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(3, 4)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_tree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_leaves)
	end
	end
	end
	for i=1,8 do
		local xi = pr:next(x-2, x+1)
		local yi = pr:next(maxy-1, maxy+1)
		local zi = pr:next(z-2, z+1)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_leaves)
		end
		end
		end
	end
end

function add_jungletree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(7, 11)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_jungletree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_jungleleaves)
	end
	end
	end
	for i=1,30 do
		local xi = pr:next(x-3, x+2)
		local yi = pr:next(maxy-2, maxy+1)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_jungleleaves)
		end
		end
		end
	end
end

function add_savannatree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(7, 11)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_savannatree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
	end
	end
	end
	for i=1,20 do
		local xi = pr:next(x-3, x+2)
		local yi = pr:next(maxy-2, maxy)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
		end
		end
		end
	end
	for i=1,15 do
		local xi = pr:next(x-3, x+2)
		local yy = pr:next(maxy-6, maxy-5)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			if minp.y<=yy and maxp.y>=yy then
				add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
			end
		end
		end
	end
end

function add_savannabush(data, a, x, y, z, minp, maxp, pr)
	local bh = pr:next(1, 2)
	local bw = pr:next(2, 4)

	for xx=math.max(minp.x, x-bw), math.min(maxp.x, x+bw) do
		for zz=math.max(minp.z, z-bw), math.min(maxp.z, z+bw) do
			for yy=math.max(minp.y, y-bh), math.min(maxp.y, y+bh) do
				if pr:next(1, 100) < 95 and math.abs(xx-x) < pr:next(bh, bh+2)-math.abs(y-yy) and math.abs(zz-z) < pr:next(bh, bh+2)-math.abs(y-yy) then
					add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
					for yyy=math.max(minp.y, yy-2), yy do
						add_leaves(data, a:index(xx, yyy, zz), c_savannaleaves)
					end
				end
			end
		end
	end

	if x<=maxp.x and x>=minp.x and y<=maxp.y and y>=minp.y and z<=maxp.z and z>=minp.z then
		local vi = a:index(x, y, z)
		data[vi] = c_savannatree
	end
end

function add_pinetree(data, a, x, y, z, minp, maxp, pr, snow)
	if snow == nil then snow = c_snow end
	local th = pr:next(9, 13)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_pinetree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-3), math.min(maxp.x, x+3) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy-1) do
	for zz=math.max(minp.z, z-3), math.min(maxp.z, z+3) do
		if pr:next(1, 100) < 80 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-2), math.min(maxp.x, x+2) do
	for yy=math.max(minp.y, maxy), math.min(maxp.y, maxy) do
	for zz=math.max(minp.z, z-2), math.min(maxp.z, z+2) do
		if pr:next(1, 100) < 85 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy+1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		if pr:next(1, 100) < 90 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	if maxy+1<=maxp.y and maxy+1>=minp.y then
		add_leaves(data, a:index(x, maxy+1, z), c_pineleaves, snow)
		add_leaves(data, a:index(x, maxy+2, z), snow)
	end
	local my = 0
	for i=1,20 do
		local xi = pr:next(x-3, x+2)
		local yy = pr:next(maxy-6, maxy-5)
		local zi = pr:next(z-3, z+2)
		if yy > my then
			my = yy
		end
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			if minp.y<=yy and maxp.y>=yy then
				add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
				add_leaves(data, a:index(xx, yy+1, zz), snow)
			end
		end
		end
	end
	for xx=math.max(minp.x, x-2), math.min(maxp.x, x+2) do
	for yy=math.max(minp.y, my+1), math.min(maxp.y, my+1) do
	for zz=math.max(minp.z, z-2), math.min(maxp.z, z+2) do
		if pr:next(1, 100) < 85 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, my+2), math.min(maxp.y, my+2) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		if pr:next(1, 100) < 90 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/ores.lua")

function get_biome_table(minp, humidity, temperature, range)
	if range == nil then range = 1 end
	local l = {}
	for xi = -range, range do
	for zi = -range, range do
		local mnp, mxp = {x=minp.x+xi*80,z=minp.z+zi*80}, {x=minp.x+xi*80+80,z=minp.z+zi*80+80}
		local pr = PseudoRandom(get_bseed(mnp))
		local bxp, bzp = pr:next(mnp.x, mxp.x), pr:next(mnp.z, mxp.z)
		local h, t = humidity:get2d({x=bxp, y=bzp}), temperature:get2d({x=bxp, y=bzp})
		l[#l+1] = {x=bxp, z=bzp, h=h, t=t}
	end
	end
	return l
end

local function get_distance(x1, x2, z1, z2)
	return (x1-x2)*(x1-x2)+(z1-z2)*(z1-z2)
end

function get_nearest_biome(biome_table, x, z)
	local m = math.huge
	local k = 0
	for key, bdef in ipairs(biome_table) do
		local dist = get_distance(bdef.x, x, bdef.z, z)
		if dist<m then
			m=dist
			k=key
		end
	end
	return biome_table[k]
end

local function get_perlin_map(seed, octaves, persistance, scale, minp, maxp)
	local sidelen = maxp.x - minp.x +1
	local pm = minetest.get_perlin_map(
                {offset=0, scale=1, spread={x=scale, y=scale, z=scale}, seed=seed, octaves=octaves, persist=persistance},
                {x=sidelen, y=sidelen, z=sidelen}
        )
        return pm:get2dMap_flat({x = minp.x, y = minp.z, z = 0})
end

local function copytable(t)
	local t2 = {}
	for key, val in pairs(t) do
		t2[key] = val
	end
	return t2
end

local function mg_generate(minp, maxp, emin, emax, vm)
	local a = VoxelArea:new{
		MinEdge={x=emin.x, y=emin.y, z=emin.z},
		MaxEdge={x=emax.x, y=emax.y, z=emax.z},
	}
	
	local treemin = {x=emin.x, y=minp.y, z=emin.z}
	local treemax = {x=emax.x, y=maxp.y, z=emax.z}
	
	local sidelen = maxp.x-minp.x+1
	
	local noise1 = get_perlin_map(12345, 6, 0.5, 256, minp, maxp)
	local noise2 = get_perlin_map(56789, 6, 0.5, 256, minp, maxp)
	local noise3 = get_perlin_map(42, 3, 0.5, 32, minp, maxp)
	local noise4 = get_perlin_map(8954, 8, 0.5, 1024, minp, maxp)
	
	local noise1raw = minetest.get_perlin(12345, 6, 0.5, 256)
	
	local vcr = VILLAGE_CHECK_RADIUS
	local villages = {}
	local generate_new_villages = true;
	for xi = -vcr, vcr do
	for zi = -vcr, vcr do
		for _, village in ipairs(mg_villages.villages_at_point({x = minp.x + xi * 80, z = minp.z + zi * 80}, noise1raw)) do
			village.to_grow = {}
			villages[#villages+1] = village
		end
		-- check if the village exists already
		local v_nr = 1;
		for v_nr, village in ipairs(villages) do
			local village_id = tostring( village.vx )..':'..tostring( village.vz );
			if( mg_villages.all_villages and mg_villages.all_villages[ village_id ]) then
				villages[ v_nr ] = mg_villages.all_villages[ village_id ];
				generate_new_villages = false;
			end
		end
	end
	end
	
	
	local pr = PseudoRandom(get_bseed(minp))
	
	local village_noise = minetest.get_perlin(7635, 3, 0.5, 16)
	local village_noise_map = get_perlin_map(7635, 3, 0.5, 16, minp, maxp)
	
	local noise_top_layer = get_perlin_map(654, 6, 0.5, 256, minp, maxp)
	local noise_second_layer = get_perlin_map(123, 6, 0.5, 256, minp, maxp)
	
	local noise_temperature_raw = minetest.get_perlin(763, 7, 0.5, 512)
	local noise_humidity_raw = minetest.get_perlin(834, 7, 0.5, 512)
	local noise_temperature = get_perlin_map(763, 7, 0.5, 512, minp, maxp)
	local noise_humidity = get_perlin_map(834, 7, 0.5, 512, minp, maxp)
	local noise_beach = get_perlin_map(452, 6, 0.5, 256, minp, maxp)
	
	local biome_table = get_biome_table(minp, noise_humidity_raw, noise_temperature_raw)
	
	local data = vm:get_data()
	local param2_data = vm:get_param2_data()

	local last_counted_surface    = c_dirt;
	local count_surface_materials = {};
--	count_surface_materials[ c_ice   ] = 0;
--	count_surface_materials[ c_water ] = 0;
--	count_surface_materials[ c_dirt  ] = 0;
--	count_surface_materials[ c_dry_grass   ] = 0;
--	count_surface_materials[ c_grass       ] = 0;
--	count_surface_materials[ c_sand        ] = 0;
--	count_surface_materials[ c_desert_sand ] = 0;
--	count_surface_materials[ c_dirt_snow   ] = 0;
--	count_surface_materials[ c_snowblock   ] = 0;
--	count_surface_materials[ c_air         ] = 0;
--	count_surface_materials[ c_snow        ] = 0;
	local block_nr = 1;
	local surface_mat = { c_ice, c_water, c_dirt, c_dry_grass, c_grass, c_sand, c_desert_sand, c_dirt_snow, c_snowblock, c_air, c_snow };
	for _,m in ipairs(surface_mat) do
		count_surface_materials[ m ] = {};
		for block_nr = 1,25 do
			count_surface_materials[ m ][ block_nr ] = 0;
		end		
	end

	local ni = 1
	local above_top
	local liquid_top
	local top
	local top_layer
	local second_layer
	local humidity
	local temperature
	local villages_to_grow = {}
	local ni = 0
	for z = minp.z, maxp.z do
	for x = minp.x, maxp.x do
		block_nr =  math.floor((maxp.x - x)/16)*5 +  math.floor((maxp.z - z)/16) + 1;
		ni = ni + 1
		local y = math.floor(surface_at_point(x, z, village_noise_map, villages, ni, noise1, noise2, noise3, noise4))
		humidity = noise_humidity[ni]
		temperature = noise_temperature[ni] - math.max(y, 0)/50
		biome = get_nearest_biome(biome_table, x, z)
		biome_humidity = biome.h
		biome_temperature = biome.t
		if biome_temperature<-0.4 then
			liquid_top = c_ice
		else
			liquid_top = c_water
		end
		if y < -1 then
			above_top = c_air
			top = c_dirt
			top_layer = c_dirt
			second_layer = c_stone
		elseif y < 3 and noise_beach[ni]<0.2 then
			above_top = c_air
			top = c_sand
			top_layer = c_sand
			second_layer = c_sandstone
		else
			above_top = c_air
			if biome_temperature>0.4 then
				if biome_humidity<-0.4 then
					top = c_desert_sand
					top_layer = c_desert_sand
					second_layer = c_desert_stone
				elseif biome_humidity<0.4 then
					top = c_dry_grass
					top_layer = c_dirt
					second_layer = c_stone
				else
					top = c_grass
					top_layer = c_dirt
					second_layer = c_stone
				end
			elseif biome_temperature<-0.4 then
				above_top = c_snow
				top = c_dirt_snow
				top_layer = c_dirt
				second_layer = c_stone
			else
				top = c_grass
				top_layer = c_dirt
				second_layer = c_stone
			end
		end
		if y>=100 then
			above_top = c_air
			top = c_snow
			top_layer = c_snowblock
		end
		if y<0 then
			above_top = c_air
		end
		if y<=maxp.y and y>=minp.y then
				local vi = a:index(x, y, z)
				if y >= 0 then
					data[vi] = top
					count_surface_materials[ top       ][ block_nr ] = count_surface_materials[ top       ][ block_nr ] + 1;
					last_counted_surface = top;
				else
					data[vi] = top_layer
					count_surface_materials[ top_layer ][ block_nr ] = count_surface_materials[ top_layer ][ block_nr ] + 1;
					last_counted_surface = top_layer;
				end
		end

		local add_above_top = true
		for id, tree in ipairs(mg.registered_trees) do
			if tree.min_humidity <= humidity and humidity <= tree.max_humidity
				and tree.min_temperature <= temperature and temperature <= tree.max_temperature
				and tree.min_biome_humidity <= biome_humidity and biome_humidity <= tree.max_biome_humidity
				and tree.min_biome_temperature <= biome_temperature and biome_temperature <= tree.max_biome_temperature
				and tree.min_height <= y+1 and y+1 <= tree.max_height
				and ((not tree.grows_on) or tree.grows_on == top)
				and pr:next(1, tree.chance) == 1 then
					local in_village = false
					for _, village in ipairs(villages) do
						if inside_village(x, z, village, village_noise) and not tree.can_be_in_village then
							if( generate_new_villages ) then
								village.to_grow[#village.to_grow+1] = {x = x, y = y + 1, z = z, id = id}
--print('ADDING a tree inside a village at '..minetest.serialize( {x = x, y = y + 1, z = z, id = id} ));
							end
							in_village = true
							break
						end
					end
					if not in_village then
						tree.grow(data, a, x, y+1, z, minp, maxp, pr)
					end
					add_above_top = false
					break
			end
		end
		if add_above_top and y+1<=maxp.y and y+1>=minp.y then
			local vi = a:index(x, y+1, z)
			data[vi] = above_top
		end
		if y<0 and minp.y<=0 and maxp.y>y then
			for yy = math.max(y+1, minp.y), math.min(0, maxp.y) do
				local vi = a:index(x, yy, z)
				data[vi] = c_water
			end
			if maxp.y>=0 then
				data[a:index(x, 0, z)] = liquid_top
				
				-- previously, we did count the ocean floor
				count_surface_materials[ last_counted_surface ][ block_nr ] = count_surface_materials[ last_counted_surface ][ block_nr ] - 1;
				count_surface_materials[ liquid_top           ][ block_nr ] = count_surface_materials[ liquid_top           ][ block_nr ] + 1;
			end
		end
		local tl = math.floor((noise_top_layer[ni]+2.5)*2)
		if y-tl-1<=maxp.y and y-1>=minp.y then
			for yy = math.max(y-tl-1, minp.y), math.min(y-1, maxp.y) do
				local vi = a:index(x, yy, z)
				data[vi] = top_layer
			end
		end
		local sl = math.floor((noise_second_layer[ni]+5)*3)
		if y-sl-1<=maxp.y and y-tl-2>=minp.y then
			for yy = math.max(y-sl-1, minp.y), math.min(y-tl-2, maxp.y) do
				local vi = a:index(x, yy, z)
				data[vi] = second_layer
			end
		end
		if y-sl-2>=minp.y then
			for yy = minp.y, math.min(y-sl-2, maxp.y) do
				local vi = a:index(x, yy, z)
				data[vi] = c_stone
			end
		end
	end
	end


	local curr_surface_max = {};
	local curr_surface_mat = {};
	local all_surface_nodes = 0;
	local count_surface_choices = {};
	local curr_chunk_max = 0;
	local curr_chunk_mat = c_dirt;
	for block_nr = 1, 25 do
		curr_surface_max[ block_nr ] = 0;
		curr_surface_mat[ block_nr ] = c_dirt;
		for k, v in pairs( count_surface_materials ) do
			if( v[ block_nr ] > curr_surface_max[ block_nr ] ) then
				curr_surface_max[ block_nr ] = v[ block_nr ];
				curr_surface_mat[ block_nr ] = k;
			end
			all_surface_nodes = all_surface_nodes + v[ block_nr ];
		end

		-- determine a chunk-wise "global" maximum (for 80x80 nodes) over all sub-mapblocks (of 16x16 nodes each)
		if( not( count_surface_choices[ curr_surface_mat[ block_nr ] ])) then
			count_surface_choices[ curr_surface_mat[ block_nr ] ] = 1;
		else
			count_surface_choices[ curr_surface_mat[ block_nr ] ] = count_surface_choices[ curr_surface_mat[ block_nr ] ] + 1;
		end
		if( count_surface_choices[ curr_surface_mat[ block_nr ] ] > curr_chunk_max ) then
			curr_chunk_mat = curr_surface_mat[ block_nr ];
			curr_chunk_max = count_surface_choices[ curr_surface_mat[ block_nr ] ];
		end
	end
	curr_surface_mat[ 26 ] = curr_chunk_mat;

	-- store information about already generated mapchunks; but only if there is any surface worth speaking off;
	-- chunks that are below ground are ignored entirely
	if( maxp.y>0 and all_surface_nodes > 1800 and #curr_surface_mat == 26 ) then 
		-- the map extends about 32000 blocks in each direction from the center; thus, if we map only 1/80 of that, 800x800 fields are enough
		-- a two-dimensional array is easier to handle later on than a computed index
		local x_index = math.floor( minp.x/80 );
		if( not( mg_villages.mg_generated_map[ x_index ] )) then
			mg_villages.mg_generated_map[ x_index ] = {};
		end
		mg_villages.mg_generated_map[ x_index ][ math.floor( minp.z/80 ) ] = curr_surface_mat;
		save_restore.save_data( 'mg_generated_map.data', mg_villages.mg_generated_map );
	end
	
	local va = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
	
	for _, ore_sheet in ipairs(mg.registered_ore_sheets) do
		local sidelen = maxp.x - minp.x + 1
		local np = copytable(ore_sheet.noise_params)
		np.seed = np.seed + minp.y
		local pm = minetest.get_perlin_map(np, {x=sidelen, y=sidelen, z=1})
		local map = pm:get2dMap_flat({x = minp.x, y = minp.z})
		local ni = 0
		local trh = ore_sheet.threshhold
		local wherein = minetest.get_content_id(ore_sheet.wherein)
		local ore = minetest.get_content_id(ore_sheet.name)
		local hmin = ore_sheet.height_min
		local hmax = ore_sheet.height_max
		local tmin = ore_sheet.tmin
		local tmax = ore_sheet.tmax
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			ni = ni+1
			local noise = map[ni]
			if noise > trh then
				local thickness = pr:next(tmin, tmax)
				local y0 = math.floor(minp.y + (noise-trh)*4)
				for y = math.max(y0, hmin), math.min(y0+thickness-1, hmax) do
					local vi = a:index(x, y, z)
					if data[vi] == wherein or wherein == c_ignore then
						data[vi] = ore
					end
				end
			end
		end
		end
	end
	for _, ore in ipairs(mg.registered_ores) do
		generate_vein(minetest.get_content_id(ore.name), minetest.get_content_id(ore.wherein), minp, maxp, ore.seeddiff, ore, data, a, va)
	end
	
	local top_node = 'default:dirt_with_grass';
 	-- replace dirt_with_grass with whatever is common in that biome
	if(     top == c_sand       ) then top_node = 'default:sand';
	elseif( top == c_dsert_sand ) then top_node = 'default:desert_sand';
	elseif( top == c_dry_grass  ) then top_node = 'mg:dirt_with_dry_grass';
	elseif( top == c_dirt_snow  ) then top_node = 'default:dirt_with_snow';
	else                               top_node = 'default:dirt_with_grass';
	end

	for _, village in ipairs(villages) do
		village.to_add_data = mg_villages.generate_village(village, minp, maxp, data, param2_data, a, village_noise, top_node)
	end

	vm:set_data(data)
	vm:set_param2_data(param2_data)

	vm:calc_lighting(
		{x=minp.x-16, y=minp.y, z=minp.z-16},
		{x=maxp.x+16, y=maxp.y, z=maxp.z+16}
	)

	vm:write_to_map(data)

	local meta
	for _, village in ipairs(villages) do
		for _, n in pairs(village.to_add_data.extranodes) do
			minetest.set_node(n.pos, n.node)
			if n.meta ~= nil then
				meta = minetest.get_meta(n.pos)
				meta:from_table(n.meta)
				if n.node.name == "default:chest" then
					local inv = meta:get_inventory()
					local items = inv:get_list("main")
					for i=1, inv:get_size("main") do
						inv:set_stack("main", i, ItemStack(""))
					end
					local numitems = pr:next(3, 20)
					for i=1,numitems do
						local ii = pr:next(1, #items)
						local prob = items[ii]:get_count() % 2 ^ 8
						local stacksz = math.floor(items[ii]:get_count() / 2 ^ 8)
						if pr:next(0, prob) == 0 and stacksz>0 then
							stk = ItemStack({name=items[ii]:get_name(), count=pr:next(1, stacksz), wear=items[ii]:get_wear(), metadata=items[ii]:get_metadata()})
							local ind = pr:next(1, inv:get_size("main"))
							while not inv:get_stack("main",ind):is_empty() do
								ind = pr:next(1, inv:get_size("main"))
							end
							inv:set_stack("main", ind, stk)
						end
					end
				end
			end
		end

		-- now add those buildings which are .mts files and need to be placed by minetest.place_schematic(...)
		mg_villages.place_schematics( village.to_add_data.bpos, village.to_add_data.replacements, a, pr );

		if( not( mg_villages.all_villages )) then
			mg_villages.all_villages = {};
		end
		-- unique id - there can only be one village at a given pair of x,z coordinates
		local village_id = tostring( village.vx )..':'..tostring( village.vz );	
		-- the village data is saved only once per village - and not whenever part of the village is generated
		if( not( mg_villages.all_villages[ village_id ])) then

			-- count how many villages we already have and assign each village a uniq number
			local count = 1;
			for _,v in pairs( mg_villages.all_villages ) do
				count = count + 1;
			end
			village.nr = count;
			mg_villages.anz_villages = count;
			mg_villages.all_villages[ village_id ] = minetest.deserialize( minetest.serialize( village ));

			print("Village No. "..tostring( count ).." of type \'"..tostring( village.village_type ).."\' of size "..tostring( village.vs ).." spawned at: x = "..village.vx..", z = "..village.vz)
			save_restore.save_data( 'mg_all_villages.data', mg_villages.all_villages );
		end
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	mg_generate(minp, maxp, emin, emax, vm)
end)

local function mg_regenerate(pos, name)
	local minp = {x = 80*math.floor((pos.x+32)/80)-32,
			y = 80*math.floor((pos.y+32)/80)-32,
			z = 80*math.floor((pos.z+32)/80)-32}
	local maxp = {x = minp.x+79, y = minp.y+79, z = minp.z+79}
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local data = {}
	for i = 1, (maxp.x-minp.x+1)*(maxp.y-minp.y+1)*(maxp.z-minp.z+1) do
		data[i] = c_air
	end
	vm:set_data(data)
	vm:write_to_map()
	mg_generate(minp, maxp, emin, emax, vm)
	
	minetest.chat_send_player(name, "Regenerating done, fixing lighting. This may take a while...")
	-- Fix lighting
	local nodes = minetest.find_nodes_in_area(minp, maxp, "air")
	local nnodes = #nodes
	local p = math.floor(nnodes/5)
        local dig_node = minetest.dig_node
        for _, pos in ipairs(nodes) do
                dig_node(pos)
                if _%p == 0 then
                	minetest.chat_send_player(name, math.floor(_/nnodes*100).."%")
                end
        end
        minetest.chat_send_player(name, "Done")
end

minetest.register_chatcommand("mg_regenerate", {
	privs = {server = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local pos = player:getpos()
			mg_regenerate(pos, name)
		end
	end,
})

local function spawnplayer(player)
	local noise1 = minetest.get_perlin(12345, 6, 0.5, 256)
	local min_dist = math.huge
	local min_pos = {x = 0, y = 3, z = 0}
	for bx = -20, 20 do
	for bz = -20, 20 do
		local minp = {x = -32 + 80 * bx, y = -32, z = -32 + 80 * bz}
		for _, village in ipairs(mg_villages.villages_at_point(minp, noise1)) do
			if math.abs(village.vx) + math.abs(village.vz) < min_dist then
				min_pos = {x = village.vx, y = village.vh + 2, z = village.vz}
				min_dist = math.abs(village.vx) + math.abs(village.vz)
			end
		end
	end
	end
	player:setpos(min_pos)
end

minetest.register_on_newplayer(function(player)
	spawnplayer(player)
end)

minetest.register_on_respawnplayer(function(player)
	spawnplayer(player)
	return true
end)

mg.registered_ores = {}
function mg.register_ore(oredef)
	if oredef.wherein == nil then
		oredef.wherein = "ignore"
	end
	if DEBUG then
		oredef.wherein = "ignore"
		oredef.maxheight = 31000
	end
	mg.registered_ores[#mg.registered_ores+1] = oredef
end

mg.registered_ore_sheets = {}
function mg.register_ore_sheet(oredef)
	if oredef.wherein == nil then
		oredef.wherein = "ignore"
	end
	if DEBUG then
		oredef.wherein = "ignore"
		oredef.height_max = 31000
	end
	mg.registered_ore_sheets[#mg.registered_ore_sheets+1] = oredef
end

mg.registered_trees = {}
function mg.register_tree(treedef)
	if treedef.min_humidity == nil then
		treedef.min_humidity = -2
	end
	if treedef.max_humidity == nil then
		treedef.max_humidity = 2
	end
	if treedef.min_biome_humidity == nil then
		treedef.min_biome_humidity = -2
	end
	if treedef.max_biome_humidity == nil then
		treedef.max_biome_humidity = 2
	end
	if treedef.min_temperature == nil then
		treedef.min_temperature = -2
	end
	if treedef.max_temperature == nil then
		treedef.max_temperature = 2
	end
	if treedef.min_biome_temperature == nil then
		treedef.min_biome_temperature = -2
	end
	if treedef.max_biome_temperature == nil then
		treedef.max_biome_temperature = 2
	end
	mg.registered_trees[#mg.registered_trees+1] = treedef
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/oredesc.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/trees.lua")

if ENABLE_SNOW then
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/snow.lua")
end
