

-- villages up to this many nodes in each direction are shown on the map
mg.MAP_RANGE = 1000;


mg.map_of_world = function( pname )

	local player = minetest.get_player_by_name( pname );
	if( not( player )) then
		return '';
	end
	local ppos  = player:getpos();

	-- also usable: diamond_block, sand, water
	local formspec = "size[14.4,10]"..
			"background[0,0;10,10;default_grass.png]"..
			"label[10,10;x axis]"..
			"label[0,0;z axis]"..
			"label[0,10;|]"..
			"label[0.2,10;->]";

	local r  = mg.MAP_RANGE;
	local f1 = 10/(2*r);
	local shown_villages = {};

	for name,v in pairs( mg.mg_all_villages ) do

		local data = v; --minetest.deserialize( v );
		local x = data.vx - ppos.x;
		local z = data.vz - ppos.z;
		local image = mg.mg_village_sizes[ data.village_type ].texture;

		-- show only villages which are at max mg.MAP_RANGE away from player
		if( x and z and image
		   and math.abs( x ) < r
		   and math.abs( z ) < r ) then

			-- the village size determines the texture size
			local d = f1 * (data.vs*2);

			-- center the village texture
			x = x - (data.vs/2);
			z = z + (data.vs/2);

			-- calculate the position for the village texture
			x = f1 * (x+r);
			z = f1 * ( (2*r) -(z+r));

			formspec = formspec..
				"label["..x..",".. z ..";"..tostring( data.nr ).."]"..
				"image["..x..",".. z ..";"..d..","..d..";" .. image .."]";

			shown_villages[ #shown_villages+1 ] = tostring( data.nr )..". "..tostring( name ).."]"; -- TODO: use real village name
		end
	end

	-- code and arrows taken from mapp mod
	local yaw = player:get_look_yaw()
	local rotate = 0;
	if yaw ~= nil then
		-- Find rotation and texture based on yaw.
		yaw = math.deg(yaw)
		yaw = math.fmod (yaw, 360)
		if yaw<0 then yaw = 360 + yaw end
		if yaw>360 then yaw = yaw - 360 end
		if yaw < 90 then
			rotate = 90
		elseif yaw < 180 then
			rotate = 180
		elseif yaw < 270 then
			rotate = 270
		else
			rotate = 0
		end
		yaw = math.fmod(yaw, 90)
		yaw = math.floor(yaw / 10) * 10

	end

	-- show the players yaw
	if rotate ~= 0 then
		formspec = formspec.."image[".. 4.95 ..",".. 4.85 ..";0.4,0.4;d" .. yaw .. ".png^[transformFYR".. rotate .."]"
	else
		formspec = formspec.."image[".. 4.95 ..",".. 4.85 ..";0.4,0.4;d" .. yaw .. ".png^[transformFY]"
	end

	local i = 0.05;
	formspec = formspec.."label[10,-0.4;Village types:]";
	-- explain the meaning of the textures
	for typ,data in pairs(mg.mg_village_sizes) do
		formspec = formspec.."label[10.5,"..tostring(i)..";"..tostring( typ ).."]"..
			             "image[10.0,"..tostring(i+0.1)..";0.4,0.4;"..tostring( data.texture ).."]";
		i = i+0.45;
	end

	i = i+0.45;
	formspec = formspec.."label[10.0,"..tostring(i)..";Villages shown on this map:]";
	i = i+0.45;
	local j = 1;
	while (i<10.5 and j<=#shown_villages) do
		
		formspec = formspec.."label[10.0,"..tostring(i)..";"..tostring( shown_villages[ j ] ).."]";
		i = i+0.45;
		j = j+1;
	end

	return formspec;
end


minetest.register_chatcommand( 'vmap', {
	description = "Shows a map of all known villages withhin "..tostring( mg.MAP_RANGE ).." blocks.",
	privs = {},
	func = function(name, param)
		minetest.show_formspec( name, 'mg:world_map', mg.map_of_world( name ));
        end
});

