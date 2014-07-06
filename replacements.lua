
nvillages = {}

-- Note: This function is taken from the villages mod (by Sokomine)
-- at least the cottages may come in a variety of building materials
-- IMPORTANT: don't add any nodes which have on_construct here UNLESS they where in the original file already
--            on_construct will only be called for known nodes that need that treatment (see villages.analyze_mts_file and on_constr)
nvillages.get_replacement_list = function( housetype, pr, dirt_with_grass_replacement )

   local replacements = {};

  -- else some grass would never (re)grow (if it's below a roof)
   table.insert( replacements, {'default:dirt',            dirt_with_grass_replacement });
   table.insert( replacements, {'default:dirt_with_grass', dirt_with_grass_replacement });

   -- nodes that accidently got into the schematics and are to be ignored
   table.insert( replacements, {'junglegrass:shortest',    'air' });
   table.insert( replacements, {'hydro:wild_peas',         'air' });
   table.insert( replacements, {'moreblocks:slab_cobble',  'stairs:slab_cobble' });

   -- Taokis houses from structure i/o
   if( housetype == 'taoki' ) then  

      table.insert( replacements, {'default:wood',          'default:clay'});
      table.insert( replacements, {'stairs:slab_wood',      'stairs:slab_sandstone'});
      -- I don't like brick roofs that much
      table.insert( replacements, {'default:brick',         'default:stone'});
      table.insert( replacements, {'stairs:slab_brick',     'stairs:slab_stone'});

      return replacements;
   end


   if( housetype == 'nore' ) then
      local materials = {'default:stonebrick', 'default:desert_stonebrick','default:sandstonebrick', 'default:sandstone','default:stone','deafult:desertstone'};
      local m1 = materials[ pr:next( 1, #materials )];
      if( m1 ~= 'default:stonebrick' ) then
         table.insert( replacements, {'default:stonebrick', m1 });
      end

      -- replace the wood as well
      local c = pr:next( 1, 4 );
      if( c==2 ) then
         table.insert( replacements, {'default:tree', 'default:jungletree' });
         table.insert( replacements, {'default:wood', 'default:junglewood' });
      elseif( c==3 ) then
         table.insert( replacements, {'default:tree', 'mg:savannatree'});
         table.insert( replacements, {'default:wood', 'mg:savannawood'});
      elseif( c==4 ) then
         table.insert( replacements, {'default:tree', 'mg:pinetree'});
         table.insert( replacements, {'default:wood', 'mg:pinewood'});
      end

      if( pr:next(1,3)==1 ) then
         table.insert( replacements, {'default:glass', 'default:obsidian_glass'});
      end

      return replacements;
   end


   if( housetype == 'logcabin' ) then

      -- for logcabins, wood is the most likely type of roof material
      local materials_roof = {'straw', 
                           'wood',  'wood', 'wood',
			   'reet', 'slate',
                           'red',
                           'brown',
                           'black'};
      local mr = materials_roof[ pr:next( 1, #materials_roof )];
      -- all three shapes of roof parts have to fit together
      table.insert( replacements, {'stairs:stair_cobble',              'cottages:roof_connector_'..mr });
      table.insert( replacements, {'stairs:slab_cobble',               'cottages:roof_flat_'..mr });
      -- some houses have junglewood roofs
      table.insert( replacements, {'stairs:stair_junglewood',          'cottages:roof_connector_'..mr });
      table.insert( replacements, {'stairs:slab_junglewood',           'cottages:roof_flat_'..mr });
      return replacements;
   end


   if( housetype == 'grasshut' ) then

      table.insert( replacements, {'moreblocks:fence_jungle_wood',     'default:fence' });
      table.insert( replacements, {'dryplants:reed_roof',              'cottages:roof_straw'});
      table.insert( replacements, {'dryplants:reed_slab',              'cottages:roof_flat_straw' });
      table.insert( replacements, {'dryplants:wetreed_roof',           'cottages:roof_reet' });
      table.insert( replacements, {'dryplants:wetreed_slab',           'cottages:roof_flat_reet' });
      table.insert( replacements, {'dryplants:wetreed_roof_corner',    'default:wood' });
      table.insert( replacements, {'dryplants:wetreed_roof_corner_2',  'default:junglewood' });
      table.insert( replacements, {'cavestuff:desert_pebble_2',        'default:slab_cobble' });
   
      return replacements;
   end


   -- TODO: are there more possible types?
   -- wells can get the same replacements as the sourrounding village; they'll get a fitting roof that way
   if( housetype ~= 'medieval' and housetype ~= 'well') then
      return {};
   end

   table.insert( replacements, {'bell:bell',               'default:goldblock' });

   -- glass that served as a marker got copied accidently; there's usually no glass in cottages
   table.insert( replacements, {'default:glass',           'air'});

-- TODO: sometimes, half_door/half_door_inverted gets rotated wrong
--   table.insert( replacements, {'cottages:half_door',      'cottages:half_door_inverted'});
--   table.insert( replacements, {'cottages:half_door_inverted', 'cottages:half_door'});

   -- some poor cottage owners cannot afford glass
   if( pr:next( 1, 2 ) == 2 ) then
      table.insert( replacements, {'cottages:glass_pane',    'default:fence_wood'});
   end

   -- 'glass' is admittedly debatable; yet it may represent modernized old houses where only the tree-part was left standing
   -- loam and clay are mentioned multiple times because those are the most likely building materials in reality
   local materials = {'cottages:loam', 'cottages:loam', 'cottages:loam', 'cottages:loam', 'cottages:loam', 
                      'default:clay',  'default:clay',  'default:clay',  'default:clay',  'default:clay',
                      'default:wood','default:junglewood','default:sandstone',
                      'default:desert_stone','default:brick','default:cobble','default:stonebrick',
                      'default:desert_stonebrick','default:sandstonebrick','default:stone','default:glass',
                      'mg:savannawood', 'mg:savannawood', 'mg:savannawood', 'mg:savannawood',
                      'mg:pinewood',    'mg:pinewood',    'mg:pinewood',    'mg:pinewood' };

   -- bottom part of the house (usually ground floor from outside)
   local m1 = materials[ pr:next( 1, #materials )];
   if( m1 ~= 'default:clay'  ) then
      if( m1 == 'mg:savannawood' ) then
         table.insert( replacements, {'default:tree',  'mg:savannatree'});
      elseif( m1 == 'mg:pinewood' ) then
         table.insert( replacements, {'default:tree',  'mg:pinetree'});
      end
      table.insert( replacements, {'default:clay',           m1});
   end
 
   -- upper part of the house (may be the same as the material for the lower part)
   local m2 = materials[ pr:next( 1, #materials )];
   if( m2 ~= 'cottages:loam' ) then
      table.insert( replacements, {'cottages:loam',          m2});
   end

   -- what is sandstone (the floor) may be turned into something else as well
   local mf = materials[ pr:next( 1, #materials )];
   -- a glass floor would go too far
   if( mf == 'default:glass' ) then 
      mf = 'cottages:loam';
   end
   if( mf ~= 'default:sandstone' ) then
      table.insert( replacements, {'default:sandstone',      mf});

      -- some houses come with slabs of the material; however, slabs are not available in all materials
      local mfs = string.sub( mf, 9 );
      -- loam and clay: use wood for slabs
      if(  mfs == ':loam' or mfs == 'clay') then 
         mfs = 'wood';
      -- for sandstonebrick, use sandstone
      elseif( mfs == 'sandstonebrick' or mfs == 'desert_stone' or mfs == 'desert_stonebrick') then
         mfs = 'sandstone';
      -- savannawood gets cut into nawood (due to mg: beeing a very short prefix); there is no stairs:slab_savannawood
      elseif( mfs == 'nawood' ) then
         mfs = 'wood';
      -- similar with pinewood: all that remains is "ood"; there is no stairs:slab_pinewood either 
      elseif( mfs == 'ood' ) then
         mfs = 'wood';
      end
      table.insert( replacements, {'stairs:slab_sandstone',   'stairs:slab_'..mfs});
   end

   -- replace cobble; for these nodes, a stony material is needed (used in wells as well)
   -- mossycobble is fine here as well
   local cob_materials = { 'default:sandstone', 'default:desert_stone',
                      'default:cobble',      'default:cobble',
                      'default:stonebrick',  'default:stonebrick', 'default:stonebrick', -- more common than other materials
                      'default:mossycobble', 'default:mossycobble','default:mossycobble',
                      'default:stone',       'default:stone',
                      'default:desert_stonebrick','default:sandstonebrick'};
   local mc = cob_materials[ pr:next( 1, #cob_materials )];
   if( mc ~= 'default:cobble' ) then
      table.insert( replacements, {'default:cobble',         mc});

      -- not all of the materials above come with slabs
      local mcs = string.sub( mc, 9 );
      -- loam and clay: use wood for slabs
      if(  mcs == 'mossycobble') then 
         mcs = 'cobble';
      -- mg does not have slabs for these
      elseif (mcs == 'desert_stone' or mcs=='desert_stonebrick' or mcs=='sandstonebrick') then
         mcs = 'sandstone';
      end
      table.insert( replacements, {'stairs:slab_cobble',      'stairs:slab_'..mcs});
   end



   -- straw is the most likely building material for roofs for historical buildings
   local materials_roof = {'straw', 'straw', 'straw', 'straw', 'straw',
			   'reet', 'reet', 'reet',
			   'slate', 'slate',
                           'wood',  'wood',  
                           'red',
                           'brown',
                           'black'};
   local mr = materials_roof[ pr:next( 1, #materials_roof )];
   if( mr ~= 'straw' ) then
      -- all three shapes of roof parts have to fit together
      table.insert( replacements, {'cottages:roof_straw',              'cottages:roof_'..mr });
      table.insert( replacements, {'cottages:roof_connector_straw',    'cottages:roof_connector_'..mr });
      table.insert( replacements, {'cottages:roof_flat_straw',         'cottages:roof_flat_'..mr });
   end
 
   return replacements;
end


-- Translate replacement function from above (which aims at place_schematic) for the villages in Nores mapgen
nvillages.get_replacement_ids = function( housetype, pr )

	local replace = {};
	local replacements = nvillages.get_replacement_list( housetype, pr );
	for i,v in ipairs( replacements ) do
		if( v and #v == 2 ) then
			replace[ minetest.get_content_id( v[1] )] = minetest.get_content_id( v[2] );
		end
	end
	return replace;
end



-- mapgen based replacements work best using a table, while minetest.place_schematic(..) based spawning needs a list
nvillages.get_replacement_table = function( housetype, pr, dirt_with_grass_replacement )

	local rtable = {};
	local replacements = nvillages.get_replacement_list( housetype, pr, dirt_with_grass_replacement );
	for i,v in ipairs( replacements ) do
		if( v and #v == 2 ) then
			rtable[ v[1] ] = v[2];
		end
	end
        return { table =  rtable, list = replacements };
end