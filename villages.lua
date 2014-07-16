VILLAGE_CHECK_RADIUS = 2
VILLAGE_CHECK_COUNT = 1
--VILLAGE_CHANCE = 28
--VILLAGE_MIN_SIZE = 20
--VILLAGE_MAX_SIZE = 40
VILLAGE_CHANCE = 28
VILLAGE_MIN_SIZE = 25
VILLAGE_MAX_SIZE = 90 --55
FIRST_ROADSIZE = 3
BIG_ROAD_CHANCE = 0

-- Enable that for really big villages (there are also really slow to generate)
--[[VILLAGE_CHECK_RADIUS = 3
VILLAGE_CHECK_COUNT = 3
VILLAGE_CHANCE = 28
VILLAGE_MIN_SIZE = 100
VILLAGE_MAX_SIZE = 150
FIRST_ROADSIZE = 5
BIG_ROAD_CHANCE = 50]]

local function is_village_block(minp)
	local x, z = math.floor(minp.x/80), math.floor(minp.z/80)
	local vcc = VILLAGE_CHECK_COUNT
	return (x%vcc == 0) and (z%vcc == 0)
end

function villages_at_point(minp, noise1)
	if not is_village_block(minp) then return {} end
	local vcr, vcc = VILLAGE_CHECK_RADIUS, VILLAGE_CHECK_COUNT
	-- Check if there's another village nearby
	for xi = -vcr, vcr, vcc do
	for zi = -vcr, 0, vcc do
		if xi ~= 0 or zi ~= 0 then
			local mp = {x = minp.x + 80*xi, z = minp.z + 80*zi}
			local pi = PseudoRandom(get_bseed(mp))
			local s = pi:next(1, 400)
			local x = pi:next(mp.x, mp.x + 79)
			local z = pi:next(mp.z, mp.z + 79)
			if s <= VILLAGE_CHANCE and noise1:get2d({x = x, y = z}) >= -0.3 then return {} end
		end
	end
	end
	local pr = PseudoRandom(get_bseed(minp))
	if pr:next(1, 400) > VILLAGE_CHANCE then return {} end -- No village here
	local x = pr:next(minp.x, minp.x + 79)
	local z = pr:next(minp.z, minp.z + 79)
	if noise1:get2d({x = x, y = z}) < -0.3 then return {} end -- Deep in the ocean
	local village_type = mg_village_types[ pr:next(1, #mg_village_types )]; -- select a random type
	if( not( mg_village_sizes[ village_type ] )) then
		mg_village_sizes[ village_type ] = { min = VILLAGE_MIN_SIZE, max = VILLAGE_MAX_SIZE };
	end
	local size = pr:next(mg_village_sizes[ village_type ].min, mg_village_sizes[ village_type ].max) -- TODO: change to type-dependant sizes
	local height = pr:next(5, 20)

--	print("A village of type \'"..tostring( village_type ).."\' of size "..tostring( size ).." spawned at: x = "..x..", z = "..z)
	--print("A village spawned at: x = "..x..", z = "..z)
	return {{vx = x, vz = z, vs = size, vh = height, village_type = village_type}}
end

--local function dist_center2(ax, bsizex, az, bsizez)
--	return math.max((ax+bsizex)*(ax+bsizex),ax*ax)+math.max((az+bsizez)*(az+bsizez),az*az)
--end

local function inside_village2(bx, sx, bz, sz, village, vnoise)
	return inside_village(bx, bz, village, vnoise) and inside_village(bx+sx, bz, village, vnoise) and inside_village(bx, bz+sz, village, vnoise) and inside_village(bx+sx, bz+sz, village, vnoise)
end

local function choose_building(l, pr, village_type)
	--::choose::
	local btype
	while true do
		local p = pr:next(1, 3000)
		for b, i in ipairs(buildings) do
			if i.weight[ village_type ] and i.weight[ village_type ] > 0 and i.max_weight and i.max_weight[ village_type ] and i.max_weight[ village_type ] >= p then
				btype = b
				break
			end
		end
		-- in case no building was found: take the last one that fits
		if( not( btype )) then
			for i=#buildings,1,-1 do
				if( buildings[i].weight and buildings[i].weight[ village_type ] and buildings[i].weight[ village_type ] > 0 ) then
					btype = i;
					i = 1;
				end
			end
		end
		if( not( btype )) then
			return 1;
		end
		if( #l<1
			or not( buildings[btype].avoid )
			or buildings[btype].avoid==''
			or not( buildings[ l[#l].btype ].avoid )
			or buildings[btype].avoid ~= buildings[ l[#l].btype ].avoid) then

			if buildings[btype].pervillage ~= nil then
				local n = 0
				for j=1, #l do
					if( l[j].btype == btype or (buildings[btype].typ and buildings[btype].typ == buildings[ l[j].btype ].typ)) then
						n = n + 1
					end
				end
				--if n >= buildings[btype].pervillage then
				--	goto choose
				--end
				if n < buildings[btype].pervillage then
					return btype
				end
			else
				return btype
			end
		end
	end
	--return btype
end

local function choose_building_rot(l, pr, orient, village_type)
	local btype = choose_building(l, pr, village_type)
	local rotation
	if buildings[btype].no_rotate then
		rotation = 0
	else
		if buildings[btype].orients == nil then
			buildings[btype].orients = {0,1,2,3}
		end
		rotation = (orient+buildings[btype].orients[pr:next(1, #buildings[btype].orients)])%4
	end
	local bsizex = buildings[btype].sizex
	local bsizez = buildings[btype].sizez
	if rotation%2 == 1 then
		bsizex, bsizez = bsizez, bsizex
	end
	return btype, rotation, bsizex, bsizez
end

local function placeable(bx, bz, bsizex, bsizez, l, exclude_roads)
	for _, a in ipairs(l) do
		if (a.btype ~= "road" or not exclude_roads) and math.abs(bx+bsizex/2-a.x-a.bsizex/2)<=(bsizex+a.bsizex)/2 and math.abs(bz+bsizez/2-a.z-a.bsizez/2)<=(bsizez+a.bsizez)/2 then return false end
	end
	return true
end

local function road_in_building(rx, rz, rdx, rdz, roadsize, l)
	if rdx == 0 then
		return not placeable(rx-roadsize+1, rz, 2*roadsize-2, 0, l, true)
	else
		return not placeable(rx, rz-roadsize+1, 0, 2*roadsize-2, l, true)
	end
end

local function when(a, b, c)
	if a then return b else return c end
end

local function generate_road(village, l, pr, roadsize, rx, rz, rdx, rdz, vnoise)
	local vx, vz, vh, vs = village.vx, village.vz, village.vh, village.vs
	local village_type   = village.village_type;
	local calls_to_do = {}
	local rxx = rx
	local rzz = rz
	local mx, m2x, mz, m2z, mmx, mmz
	mx, m2x, mz, m2z = rx, rx, rz, rz
	local orient1, orient2
	if rdx == 0 then
		orient1 = 0
		orient2 = 2
	else
		orient1 = 3
		orient2 = 1
	end
	while inside_village(rx, rz, village, vnoise) and not road_in_building(rx, rz, rdx, rdz, roadsize, l) do
		if roadsize > 1 and pr:next(1, 4) == 1 then
			--generate_road(vx, vz, vs, vh, l, pr, roadsize-1, rx, rz, math.abs(rdz), math.abs(rdx))
			calls_to_do[#calls_to_do+1] = {rx=rx+(roadsize - 1)*rdx, rz=rz+(roadsize - 1)*rdz, rdx=math.abs(rdz), rdz=math.abs(rdx)}
			m2x = rx + (roadsize - 1)*rdx
			m2z = rz + (roadsize - 1)*rdz
			rx = rx + (2*roadsize - 1)*rdx
			rz = rz + (2*roadsize - 1)*rdz
		end
		--else
			--::loop::
			local exitloop = false
			local bx
			local bz
			local tries = 0
			while true do
				if not inside_village(rx, rz, village, vnoise) or road_in_building(rx, rz, rdx, rdz, roadsize, l) then
					exitloop = true
					break
				end
				btype, rotation, bsizex, bsizez = choose_building_rot(l, pr, orient1, village_type)
				bx = rx + math.abs(rdz)*(roadsize+1) - when(rdx==-1, bsizex-1, 0)
				bz = rz + math.abs(rdx)*(roadsize+1) - when(rdz==-1, bsizez-1, 0)
				if placeable(bx, bz, bsizex, bsizez, l) and inside_village2(bx, bsizex, bz, bsizez, village, vnoise) then
					break
				end
				if tries > 5 then
					rx = rx + rdx
					rz = rz + rdz
					tries = 0
				else
					tries = tries + 1
				end
				--goto loop
			end
			if exitloop then break end
			rx = rx + (bsizex+1)*rdx
			rz = rz + (bsizez+1)*rdz
			mx = rx - 2*rdx
			mz = rz - 2*rdz
			l[#l+1] = {x=bx, y=vh, z=bz, btype=btype, bsizex=bsizex, bsizez=bsizez, brotate = rotation}
		--end
	end
	rx = rxx
	rz = rzz
	while inside_village(rx, rz, village, vnoise) and not road_in_building(rx, rz, rdx, rdz, roadsize, l) do
		if roadsize > 1 and pr:next(1, 4) == 1 then
			--generate_road(vx, vz, vs, vh, l, pr, roadsize-1, rx, rz, -math.abs(rdz), -math.abs(rdx))
			calls_to_do[#calls_to_do+1] = {rx=rx+(roadsize - 1)*rdx, rz=rz+(roadsize - 1)*rdz, rdx=-math.abs(rdz), rdz=-math.abs(rdx)}
			m2x = rx + (roadsize - 1)*rdx
			m2z = rz + (roadsize - 1)*rdz
			rx = rx + (2*roadsize - 1)*rdx
			rz = rz + (2*roadsize - 1)*rdz
		end
		--else
			--::loop::
			local exitloop = false
			local bx
			local bz
			local tries = 0
			while true do
				if not inside_village(rx, rz, village, vnoise) or road_in_building(rx, rz, rdx, rdz, roadsize, l) then
					exitloop = true
					break
				end
				btype, rotation, bsizex, bsizez = choose_building_rot(l, pr, orient2, village_type)
				bx = rx - math.abs(rdz)*(bsizex+roadsize) - when(rdx==-1, bsizex-1, 0)
				bz = rz - math.abs(rdx)*(bsizez+roadsize) - when(rdz==-1, bsizez-1, 0)
				if placeable(bx, bz, bsizex, bsizez, l) and inside_village2(bx, bsizex, bz, bsizez, village, vnoise) then
					break
				end
				if tries > 5 then
					rx = rx + rdx
					rz = rz + rdz
					tries = 0
				else
					tries = tries + 1
				end
				--goto loop
			end
			if exitloop then break end
			rx = rx + (bsizex+1)*rdx
			rz = rz + (bsizez+1)*rdz
			m2x = rx - 2*rdx
			m2z = rz - 2*rdz
			l[#l+1] = {x=bx, y=vh, z=bz, btype=btype, bsizex=bsizex, bsizez=bsizez, brotate = rotation}
		--end
	end
	if road_in_building(rx, rz, rdx, rdz, roadsize, l) then
		mmx = rx - 2*rdx
		mmz = rz - 2*rdz
	end
	mx = mmx or rdx*math.max(rdx*mx, rdx*m2x)
	mz = mmz or rdz*math.max(rdz*mz, rdz*m2z)
	if rdx == 0 then
		rxmin = rx - roadsize + 1
		rxmax = rx + roadsize - 1
		rzmin = math.min(rzz, mz)
		rzmax = math.max(rzz, mz)
	else
		rzmin = rz - roadsize + 1
		rzmax = rz + roadsize - 1
		rxmin = math.min(rxx, mx)
		rxmax = math.max(rxx, mx)
	end
	l[#l+1] = {x = rxmin, y = vh, z = rzmin, btype = "road",
		bsizex = rxmax - rxmin + 1, bsizez = rzmax - rzmin + 1, brotate = 0}
	for _, i in ipairs(calls_to_do) do
		local new_roadsize = roadsize - 1
		if pr:next(1, 100) <= BIG_ROAD_CHANCE then
			new_roadsize = roadsize
		end

		--generate_road(vx, vz, vs, vh, l, pr, new_roadsize, i.rx, i.rz, i.rdx, i.rdz, vnoise)
		calls[calls.index] = {village, l, pr, new_roadsize, i.rx, i.rz, i.rdx, i.rdz, vnoise}
		calls.index = calls.index+1
	end
end

local function generate_bpos(village, pr, vnoise)
	local vx, vz, vh, vs = village.vx, village.vz, village.vh, village.vs
	local l = {}
	local rx = vx - vs
	--[=[local l={}
	local total_weight = 0
	for _, i in ipairs(buildings) do
		if i.weight == nil then i.weight = 1 end
		total_weight = total_weight+i.weight
		i.max_weight = total_weight
	end
	local multiplier = 3000/total_weight
	for _,i in ipairs(buildings) do
		i.max_weight = i.max_weight*multiplier
	end
	for i=1, 2000 do
		bx = pr:next(vx-vs, vx+vs)
		bz = pr:next(vz-vs, vz+vs)
		::choose::
		--[[btype = pr:next(1, #buildings)
		if buildings[btype].chance ~= nil then
			if pr:next(1, buildings[btype].chance) ~= 1 then
				goto choose
			end
		end]]
		p = pr:next(1, 3000)
		for b, i in ipairs(buildings) do
			if i.max_weight > p then
				btype = b
				break
			end
		end
		if buildings[btype].pervillage ~= nil then
			local n = 0
			for j=1, #l do
				if l[j].btype == btype then
					n = n + 1
				end
			end
			if n >= buildings[btype].pervillage then
				goto choose
			end
		end
		local rotation
		if buildings[btype].no_rotate then
			rotation = 0
		else
			rotation = pr:next(0, 3)
		end
		bsizex = buildings[btype].sizex
		bsizez = buildings[btype].sizez
		if rotation%2 == 1 then
			bsizex, bsizez = bsizez, bsizex
		end
		if dist_center2(bx-vx, bsizex, bz-vz, bsizez)>vs*vs then goto out end
		for _, a in ipairs(l) do
			if math.abs(bx-a.x)<=(bsizex+a.bsizex)/2+2 and math.abs(bz-a.z)<=(bsizez+a.bsizez)/2+2 then goto out end
		end
		l[#l+1] = {x=bx, y=vh, z=bz, btype=btype, bsizex=bsizex, bsizez=bsizez, brotate = rotation}
		::out::
	end
	return l]=]--
	local rz = vz
	while inside_village(rx, rz, village, vnoise) do
		rx = rx - 1
	end
	rx = rx + 5
	calls = {index = 1}
	generate_road(village, l, pr, FIRST_ROADSIZE, rx, rz, 1, 0, vnoise)
	i = 1
	while i < calls.index do
		generate_road(unpack(calls[i]))
		i = i+1
	end
	return l
end

local function generate_building(pos, minp, maxp, data, param2_data, a, pr, extranodes, replacements)
	local binfo = buildings[pos.btype]
	local scm

	-- schematics of .mts type are not handled here; they need to be placed using place_schematics
	if( binfo.is_mts == 1 ) then
		return;
	end

	if( type(binfo.scm) == "string" and binfo.scm_data_cache and type(binfo.scm_data_cache)=="string" )then
		scm = minetest.deserialize( binfo.scm_data_cache ); --import_scm(binfo.scm, replacements)
	-- at first time of spawning, all nodes ought to be defined; thus, we can cache the data
	elseif( type( binfo.scm ) == "string" ) then
		scm = import_scm( buildings[ pos.btype ].scm );
		buildings[ pos.btype ].scm_data_cache = minetest.serialize( scm )
	else
		scm = binfo.scm
	end
	scm = rotate(scm, pos.brotate)
	local c_ignore = minetest.get_content_id("ignore")
	local c_air = minetest.get_content_id("air")
	for x = 0, pos.bsizex-1 do
	for y = 0, binfo.ysize-1 do
	for z = 0, pos.bsizez-1 do
		ax, ay, az = pos.x+x, pos.y+y+binfo.yoff, pos.z+z
		if (ax >= minp.x and ax <= maxp.x) and (ay >= minp.y and ay <= maxp.y) and (az >= minp.z and az <= maxp.z) then

			t = scm[y+1][x+1][z+1]

			if type(t) == "table" then
				if( t.node and t.node.name and replacements.table[ t.node.name ] ) then
					t.node.name    = replacements.table[ t.node.name ];
				end
				if( t.node and t.node.content and replacements.ids[ t.node.content ] ) then
					t.node.content = replacements.ids[   t.node.content ];
				end
				if t.extranode then
					table.insert(extranodes, {node = t.node, meta = t.meta, pos = {x = ax, y = ay, z = az}})
				else
					data[a:index(ax, ay, az)] = t.node.content
					param2_data[a:index(ax, ay, az)] = t.node.param2
				end
			-- air and gravel
			elseif t ~= c_ignore then

				if( t and replacements.ids[ t ] ) then
					t = replacements.ids[ t ];
				end
				data[a:index(ax, ay, az)] = t
			end
		end
	end
	end
	end
end



-- the dirt_with_grass_replacement for the entire mapchunk is usually not fine-graded enough for individual buildings;
-- therefore, we need to check the immediate environment of a house
mg_get_local_dirt_with_grass = function( pos, size_x, size_z )

	local types = {};
	local curr_max = 0;
	local curr_candidate = 'default:dirt_with_grass';

	-- check some positions on ground level sourrounding the area of the building;
	-- the place where the building will be may already be covered by nodes from the building due to previous spawning from neighbouring mapchunks
	local positions = {
		{ x=(pos.x          -1), y=pos.y, z=(pos.z            ) },
		{ x=(pos.x            ), y=pos.y, z=(pos.z          -1) },

		{ x=(pos.x + size_x +1), y=pos.y, z=(pos.z            ) },
		{ x=(pos.x + size_x   ), y=pos.y, z=(pos.z          -1) },

		{ x=(pos.x          -1), y=pos.y, z=(pos.z + size_z   ) },
		{ x=(pos.x            ), y=pos.y, z=(pos.z + size_z +1) },

		{ x=(pos.x + size_x +1), y=pos.y, z=(pos.z + size_z   ) },
		{ x=(pos.x + size_x   ), y=pos.y, z=(pos.z + size_z +1) },
		};

	for i, p in ipairs( positions ) do
		local n = minetest.get_node( p );
		if( n and n ~= nil and n.name and n.name ~= 'air' and n.name ~= 'ignore'
			-- only count nodes that are acceptable as replacements for dirt_with_grass
			and (n.name=='default:dirt' or n.name=='default:dirt_with_grass' or n.name=='default:dirt_with_snow' 
			     or n.name=='default:sand' or n.name=='mg:dirt_with_dry_grass')) then

			if( not( types[ n.name ] )) then
				types[ n.name ] = 1;
			else
				types[ n.name ] = types[ n.name ] + 1;
			end

			if( types[ n.name ] > curr_max ) then
				curr_max = types[ n.name ];
				curr_candidate = n.name;
			end
		end
	end
	return curr_candidate;
end


-- similar to generate_building, except that it uses minetest.place_schematic(..) instead of changing voxelmanip data;
-- this has advantages for nodes that use facedir;
-- the function is called AFTER the mapgen data has been written in init.lua
-- pr is used to determine which fruit to grow on small farms
mg_village_place_schematics = function( bpos, replacements, voxelarea, pr )

	local mts_path = minetest.get_modpath("mg").."/schems/";

	for _, pos in ipairs( bpos ) do

		local binfo = buildings[pos.btype];

		-- set fruits for all buildings in the village that need it - regardless weather they will be spawned
		-- now or later; after the first call to this function here, the village data will be final
		if( binfo.farming_plus and binfo.farming_plus == 1 and mg_fruit_list and not pos.furit) then
 			pos.fruit = mg_fruit_list[ pr:next( 1, #mg_fruit_list )];
		end

		-- We need to check all 8 corners of the building.
		-- This will only work for buildings that are smaller than chunk size (relevant here: about 111 nodes)
		-- The function only spawns buildings which are at least partly contained in this chunk/voxelarea.
		if( voxelarea
		   and ( voxelarea:contains( pos.x,              pos.y - binfo.yoff,               pos.z )
		      or voxelarea:contains( pos.x + pos.bsizex, pos.y - binfo.yoff,               pos.z )
		      or voxelarea:contains( pos.x,              pos.y - binfo.yoff,               pos.z + pos.bsizez )
		      or voxelarea:contains( pos.x + pos.bsizex, pos.y - binfo.yoff,               pos.z + pos.bsizez )
		      or voxelarea:contains( pos.x,              pos.y - binfo.yoff + binfo.ysize, pos.z )
		      or voxelarea:contains( pos.x + pos.bsizex, pos.y - binfo.yoff + binfo.ysize, pos.z )
		      or voxelarea:contains( pos.x,              pos.y - binfo.yoff + binfo.ysize, pos.z + pos.bsizez )
		      or voxelarea:contains( pos.x + pos.bsizex, pos.y - binfo.yoff + binfo.ysize, pos.z + pos.bsizez ) )) then

			-- that function places schematics, adds snow where needed and stores information about the fruit
			-- and the grass type used directly in the pos/bpos data structure
			mg_village_place_one_schematic( bpos, replacements, pos, mts_path );
		end
	end
	--print('VILLAGE DATA: '..minetest.serialize( bpos ));
end


-- also adds a snow layer for buildings spawned from .we files
mg_village_place_one_schematic = function( bpos, replacements, pos, mts_path )

	-- just for the record: count how many times this building has been placed already;
	-- multiple placements are commen at chunk boundaries (may be up to 8 placements)
	if( not( pos.count_placed )) then
		pos.count_placed = 1;
	else
		pos.count_placed = pos.count_placed + 1;
	end

	local binfo = buildings[pos.btype];

	local start_pos = { x=( pos.x           ), y=(pos.y + binfo.yoff              ), z=( pos.z )};
	local end_pos   = { x=( pos.x+pos.bsizex), y=(pos.y + binfo.yoff + binfo.ysize), z=( pos.z + pos.bsizez )};

	-- check sourrounding nodes for information on which grass type we really ought to use
	local dirt_with_grass_replacement = mg_get_local_dirt_with_grass( pos, bsizex, bsizez ); 

	-- this function is only responsible for files that are in .mts format
	if( binfo.is_mts == 1 ) then
		-- translate rotation
		local rotation = 0;
		if(     pos.brotate == 1 ) then
			rotation = 90;
		elseif( pos.brotate == 2 ) then
			rotation = 180;
		elseif( pos.brotate == 3 ) then
			rotation = 270;
		else
			rotation = 0;
		end
		if( binfo.rotated ) then
			rotation = (rotation + binfo.rotated ) % 360;
		end

		-- copy the replacement list so that there are no duplicate entries
		local new_replacements = {};
		for i, repl in ipairs( replacements ) do	
			new_replacements[ i ] = repl;
		end	

		-- they don't all grow cotton; farming_plus fruits are far more intresting!
		if( binfo.farming_plus and binfo.farming_plus == 1 and pos.fruit ) then

			for i=1,8 do
				-- farming_plus plants sometimes come in 3 or 4 variants, but not in 8 as cotton does
				if(     minetest.registered_nodes[ 'farming_plus:'..pos.fruit..'_'..i ]) then
					table.insert( new_replacements, {"farming:cotton_"..i,  'farming_plus:'..pos.fruit..'_'..i });
			
				-- "surplus" cotton variants will be replaced with the full grown fruit
				elseif( minetest.registered_nodes[ 'farming_plus:'..pos.fruit ]) then
					table.insert( new_replacements, {"farming:cotton_"..i,  'farming_plus:'..pos.fruit });

				-- and plants from farming: are supported as well
				elseif( minetest.registered_nodes[ 'farming:'..pos.fruit..'_'..i ]) then
					table.insert( new_replacements, {"farming:cotton_"..i,  'farming:'..pos.fruit..'_'..i });

				elseif( minetest.registered_nodes[ 'farming:'..pos.fruit ]) then
					table.insert( new_replacements, {"farming:cotton_"..i,  'farming:'..pos.fruit });
				end
			end
		end

		-- avoid duplicate entries
		for i, repl in ipairs( new_replacements ) do
			if( repl and #repl and #repl>1 and (repl[1]=='default:dirt_with_grass' or repl[1]=='default:dirt' )) then
				new_replacements[ i ][ 2 ] = dirt_with_grass_replacement;
			end
		end


--		print( 'PLACED BUILDING '..tostring( binfo.scm )..' AT '..minetest.pos_to_string( pos )..'. Max. size: '..tostring( max_xz )..' grows: '..tostring(fruit));
		-- force placement (we want entire buildings)
		minetest.place_schematic( start_pos, mts_path..binfo.scm..'.mts', tostring( rotation ), new_replacements, true);

		-- TODO: add snow on roofs and roof-slabs and stairs

		-- call on_construct for all the nodes that require it (i.e. furnaces)
		for i, v in ipairs( binfo.on_constr ) do

			-- there are only very few nodes which need this special treatment
			local nodes = minetest.find_nodes_in_area( start_pos, end_pos, v);

			for _, p in ipairs( nodes ) do
				minetest.registered_nodes[ v ].on_construct( p );
			end
		end

		-- note: after_place_node is not handled here because we do not have a player at hand that could be used for it
	end

	-- add snowblocks on snow nodes; this needs to be done for .mts and .we files alike;
 	-- this also changes the grass type for those nodes that do not have a fitting type
	if( dirt_with_grass_replacement ) then

		if( dirt_with_grass_replacement == 'default:dirt_with_snow' ) then
			cover = 'default:snow';
		else
			cover = nil;
		end
		local nodes = minetest.find_nodes_in_area( start_pos, end_pos, {'default:dirt','default:dirt_with_grass','default:dirt_with_snow','mg:dirt_with_dry_grass'});
		for _, p in ipairs(nodes) do
			local above = minetest.get_node( { x=p.x, y=p.y+1, z=p.z } );
			if( cover and above and above.name and above.name == 'air' ) then
				minetest.set_node( {x=p.x, y=p.y+1, z=p.z}, { name=cover} );
			end
			-- adjust the surface grass for .we files
			if( not( binfo.is_mts == 1 )) then
				local n     = minetest.get_node( p );
				if( n and n.name and n.name ~= dirt_with_grass_replacement ) then
					minetest.set_node( p, { name = dirt_with_grass_replacement } );
				end
			end
		end
	end	

	-- save the dirt_with_grass_replacement choosen for this particular building in the village data
	pos.grass_type = dirt_with_grass_replacement;

	-- TODO: fill chests etc.
end




local MIN_DIST = 1

local function pos_far_buildings(x, z, l)
	for _, a in ipairs(l) do
		if a.x - MIN_DIST <= x and x <= a.x + a.bsizex + MIN_DIST and
		   a.z - MIN_DIST <= z and z <= a.z + a.bsizez + MIN_DIST then
			return false
		end
	end
	return true
end


local function generate_walls(bpos, data, a, minp, maxp, vh, vx, vz, vs, vnoise)
	for x = minp.x, maxp.x do
	for z = minp.z, maxp.z do
		local xx = (vnoise:get2d({x=x, y=z})-2)*20+(40/(vs*vs))*((x-vx)*(x-vx)+(z-vz)*(z-vz))
		if xx>=40 and xx <= 44 then
			bpos[#bpos+1] = {x=x, z=z, y=vh, btype="wall", bsizex=1, bsizez=1, brotate=0}
		end
	end
	end
end

function generate_village(village, minp, maxp, data, param2_data, a, vnoise, dirt_with_grass_replacement)
	local vx, vz, vs, vh = village.vx, village.vz, village.vs, village.vh
	local village_type = village.village_type;
	local seed = get_bseed({x=vx, z=vz})
	local pr_village = PseudoRandom(seed)
	local bpos = generate_bpos( village, pr_village, vnoise)

	--generate_walls(bpos, data, a, minp, maxp, vh, vx, vz, vs, vnoise)
	local pr = PseudoRandom(seed)
	for _, g in ipairs(village.to_grow) do
		if pos_far_buildings(g.x, g.z, bpos) then
			mg.registered_trees[g.id].grow(data, a, g.x, g.y, g.z, minp, maxp, pr)
		end
	end

	local p = PseudoRandom(seed);
	local replacements = nvillages.get_replacement_table( village.village_type, p, dirt_with_grass_replacement );

	if( not( replacements.table )) then
		replacements.table = {};
	end

	local extranodes = {}
	for _, pos in ipairs(bpos) do
		-- replacements are in table format for mapgen-based building spawning
		generate_building(pos, minp, maxp, data, param2_data, a, pr_village, extranodes, replacements )
	end
	-- replacements are in list format for minetest.place_schematic(..) type spawning
	return { extranodes = extranodes, bpos = bpos, replacements = replacements.list };
end

