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

function village_at_point(minp, noise1)
	if not is_village_block(minp) then return 0, 0, 0, 0 end
	local vcr, vcc = VILLAGE_CHECK_RADIUS, VILLAGE_CHECK_COUNT
	for xi = -vcr, vcr, vcc do
	for zi = -vcr, 0, vcc do
		if xi ~= 0 or zi ~= 0 then
			local mp = {x = minp.x + 80*xi, z = minp.z + 80*zi}
			local pi = PseudoRandom(get_bseed(mp))
			local s = pi:next(1, 400)
			local x = pi:next(mp.x, mp.x + 79)
			local z = pi:next(mp.z, mp.z + 79)
			if s <= VILLAGE_CHANCE and noise1:get2d({x = x, y = z}) >= -0.3 then return 0, 0, 0, 0 end
		end
	end
	end
	local pr = PseudoRandom(get_bseed(minp))
	if pr:next(1, 400) > VILLAGE_CHANCE then return 0, 0, 0, 0 end
	local x = pr:next(minp.x, minp.x + 79)
	local z = pr:next(minp.z, minp.z + 79)
	if noise1:get2d({x = x, y = z}) < -0.3 then return 0, 0, 0, 0 end
	local size = pr:next(VILLAGE_MIN_SIZE, VILLAGE_MAX_SIZE)
	local height = pr:next(5, 20)
	print("A village spawned at: x = "..x..", z = "..z)
	return x, z, size, height
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
		if buildings[btype].pervillage ~= nil then
			local n = 0
			for j=1, #l do
				if l[j].btype == btype then
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
		generate_road(unpack(calls[i])) -- TODO?
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

	if type(binfo.scm) == "string" then
		scm = import_scm(binfo.scm, replacements)
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

			-- in case the assumptions about the schematics dimension where wrong: fill up with red wool
			if( not( scm[y+1] ) or not( scm[y+1][x+1] ) or not( scm[y+1][x+1][z+1] ))
				then t = minetest.get_content_id("wool:red");
			else
				t = scm[y+1][x+1][z+1]
			end
			if type(t) == "table" then
				if( t.node and t.node.name and replacements[ t.node.name ] ) then
					t.node.name = replacements[ t.node.name ];
				end
				if t.extranode then
					table.insert(extranodes, {node = t.node, meta = t.meta, pos = {x = ax, y = ay, z = az}})
				else
					data[a:index(ax, ay, az)] = t.node.content
					param2_data[a:index(ax, ay, az)] = t.node.param2
				end
			-- air and gravel
			elseif t ~= c_ignore then
				data[a:index(ax, ay, az)] = t
			end
		end
	end
	end
	end
end


-- similar to generate_building, except that it uses minetest.place_schematic(..) instead of changing voxelmanip data;
-- this has advantages for nodes that use facedir;
-- the function is called AFTER the mapgen data has been written in init.lua
place_village_buildings = function( bpos, replacements )

	local mts_path = minetest.get_modpath("mg").."/schems/";

	for _, pos in ipairs( bpos ) do

		local binfo = buildings[pos.btype];

		-- this function is only responsible for files that are in .mts format
		if( binfo.is_mts == 1 ) then

			-- translate rotation
			local rotation = "0";
			if(     pos.brotate == 1 ) then
				rotation = "90";
			elseif( pos.brotate == 2 ) then
				rotation = "180";
			elseif( pos.brotate == 3 ) then
				rotation = "270";
			else
				rotation = "0";
			end

			local p = { x = pos.x, y = pos.y, z = pos.z }; -- TODO

			--print( 'WILL BUILD: '..minetest.serialize( { p = p, file=(mts_path..binfo.scm), r=rotation, replacements=replacements, force=true}));
			-- force placement (we want entire buildings)
---			minetest.place_schematic( p, mts_path..binfo.scm..'.mts', rotation, replacements, true);

			minetest.set_node( p, {name='mg:building_spawner'});

			-- store necessary data so that the building can pop up later on
			local meta = minetest.get_meta( p );
			meta:set_string( 'building_data', minetest.serialize( { file = binfo.scm, rotation = rotation, replacements = replacements } ));
			meta:set_string( 'infotext',      'Automatic building spawner for '..tostring( binfo.scm ));
		end
	end
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


function generate_village(village, minp, maxp, data, param2_data, a, vnoise)
	local vx, vz, vs, vh = village.vx, village.vz, village.vs, village.vh
	local village_type = village.village_type;
	local seed = get_bseed({x=vx, z=vz})
	local pr_village = PseudoRandom(seed)
	local bpos = generate_bpos(village, pr_village, vnoise)

if( not( village_type )) then
--  village_type = village_types[ math.random(1, #village_types )]; -- TODO
  village_type = village_types[ ((vx+vz)%(#village_types) )+1 ]; -- TODO
end
village_type = 'medieval'; -- TODO!

	local bpos = generate_bpos(vx, vz, vs, vh, pr_village, vnoise, village_type)
--print( 'RESULT of generate_bpos: '..minetest.serialize( bpos )); -- TODO
print( 'VILLAGE TYPE: '..tostring( village_type ));
	--generate_walls(bpos, data, a, minp, maxp, vh, vx, vz, vs, vnoise)
>>>>>>> added new buildings; can now spawn diffrent village types; nodes can be replaced randomly for entire villages; support for .mts files
	local pr = PseudoRandom(seed)
	for _, g in ipairs(village.to_grow) do
		if pos_far_buildings(g.x, g.z, bpos) then
			mg.registered_trees[g.id].grow(data, a, g.x, g.y, g.z, minp, maxp, pr)
		end
	end

	local p = PseudoRandom(seed);
	local replacements = {};	
	if( village_type == 'medieval' ) then
		replacements = nvillages.get_replacement_table( 'cottages', p );
	elseif( village_type == 'nore' ) then
		replacements = nvillages.get_replacement_table( 'nore',     p );
	elseif( village_type == 'grasshut' ) then
		replacements = nvillages.get_replacement_table( 'grasshut', p );
	elseif( village_type == 'logcabin' ) then
		replacements = nvillages.get_replacement_table( 'logcabin', p );
	end
print( minetest.serialize( replacements.table )..'\n...are the replacements for '..tostring( village_type )..'.'); -- TODO
print( 'Village data: '..minetest.serialize( bpos )); -- TODO

	local extranodes = {}
	for _, pos in ipairs(bpos) do
		-- replacements are in table format for mapgen-based building spawning
		generate_building(pos, minp, maxp, data, param2_data, a, pr_village, extranodes, replacements.table )
	end
	-- replacements are in list format for minetest.place_schematic(..) type spawning
	return { extranodes = extranodes, bpos = bpos, replacements = replacements.list };
end

