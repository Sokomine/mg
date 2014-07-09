
--village_types = { 'nore', 'logcabin', 'grasshut', 'medieval', 'charachoal', 'taoki'};

mg_village_sizes = {
	nore         = { min = 20, max = 40},
	taoki        = { min = 30, max = 90},
	medieval     = { min = 25, max = 90},
	charachoal   = { min = 10, max = 15},
	lumberjack   = { min = 10, max = 20},
	claytrader   = { min = 10, max = 20},
	logcabin     = { min = 15, max = 30},
	canadian     = { min = 30, max = 90},
}

buildings = {

-- the houses the mod came with
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 9,	scm="house", orients={2},                 weight={nore=1   }},
	{sizex= 9,	sizez= 9,	yoff= 0,	ysize= 2,	scm="wheat_field",                        weight={nore=1   }},
	{sizex= 9,	sizez= 9,	yoff= 0,	ysize= 2,	scm="cotton_field",                       weight={nore=1   }},
	{sizex= 3,	sizez= 3,	yoff= 1,	ysize= 4,	scm="lamp", no_rotate=true,               weight={nore=1/5 }},
	{sizex= 4,	sizez= 4,	yoff=-5,	ysize=11,	scm="well", no_rotate=true, pervillage=1, weight={nore=1   }},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize=11,	scm="fountain", pervillage=3,             weight={nore=1/4 }},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize= 6,	scm="small_house", orients={3},           weight={nore=1   }},
	{sizex= 6,	sizez=12,	yoff= 0,	ysize= 7,	scm="house_with_garden", orients={1},     weight={nore=1   }},
	{sizex=16,	sizez=17,	yoff= 0,	ysize=12,	scm="church", orients={3}, pervillage=1,  weight={nore=1   }},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize=16,	scm="tower", orients={0},                 weight={nore=1/7 }},
	{sizex= 8,	sizez= 9,	yoff= 0,	ysize= 6,	scm="forge", orients={0}, pervillage=2,   weight={nore=1   }},
	{sizex=11,	sizez=12,	yoff= 0,	ysize= 6,	scm="library", orients={1}, pervillage=2, weight={nore=1   }},
	{sizex=15,	sizez= 7,	yoff= 0,	ysize=12,	scm="inn", orients={1}, pervillage=4,     weight={nore=1/2 }},
	{sizex=22,	sizez=17,	yoff= 0,	ysize= 7,	scm="pub", orients={3}, pervillage=2,     weight={nore=1/3 }},


-- log cabins by Sokomine (requiring cottages, glasspanes)
	{sizex= 6,	sizez= 4,	yoff= 0,	ysize= 5,	scm="logcabin1",  orients={1}, weight={logcabin=1}},
	{sizex= 6,	sizez= 6,	yoff= 0,	ysize= 6,	scm="logcabin2",  orients={1}, weight={logcabin=1}},
	{sizex= 6,	sizez= 6,	yoff= 0,	ysize= 6,	scm="logcabin3",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 7,	yoff= 0,	ysize= 7,	scm="logcabin4",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize= 5,	scm="logcabin5",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 7,	yoff= 0,	ysize= 5,	scm="logcabin6",  orients={1}, weight={logcabin=1}},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 7,	scm="logcabin7",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 6,	yoff= 0,	ysize= 5,	scm="logcabin8",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize= 6,	scm="logcabin9",  orients={1}, weight={logcabin=1}},
	{sizex= 5,	sizez= 8,	yoff= 0,	ysize= 7,	scm="logcabin10", orients={1}, weight={logcabin=1}},
	{sizex= 7,	sizez= 10,	yoff= 0,	ysize= 7,	scm="logcabin11", orients={1}, weight={logcabin=1}},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 5,	scm="logcabin12rot", orients={2}, weight={logcabin=1}},
	{sizex= 7,	sizez= 8,	yoff= 0,	ysize= 7,	scm="logcabin13rot", orients={2}, weight={logcabin=1}},

-- grass huts (requiring cottages, dryplants, cavestuff/undergrowth, plantlife)
	{sizex= 6,	sizez= 6,	yoff= 0,	ysize= 5,	scm="grasshut1", orients={2}, weight={grasshut=1}},
	{sizex= 9,	sizez= 9,	yoff= 0,	ysize= 8,	scm="grasshut2", orients={2}, weight={grasshut=1}},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 7,	scm="grasshut3", orients={2}, weight={grasshut=1}},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 7,	scm="grasshut4", orients={2}, weight={grasshut=1}},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize= 6,	scm="grasshut5", orients={2}, weight={grasshut=1}},
	{sizex= 5,	sizez= 5,	yoff= 0,	ysize= 6,	scm="grasshut6", orients={2}, weight={grasshut=1}},
	{sizex= 7,	sizez= 7,	yoff= 0,	ysize= 2,	scm="grasshutcenter", orients={2}, pervillage=1, weight={grasshut=2}},

-- for the buildings below, sizex, sizez and ysize are read from the file directly;
-- the entries "avoid" and "typ" are not used here

-- schematics from Sokomines villages mod (requires cottages)
	{scm="church_1",        yoff= 0, orients={0}, farming_plus=0, avoid='', typ='church',    weight={medieval=4}, pervillage=1},    
	{scm="forge_1",         yoff= 0, orients={0}, farming_plus=0, avoid='', typ='forge',     weight={medieval=2}, pervillage=1},
	{scm="mill_1",          yoff= 0, orients={0}, farming_plus=0, avoid='', typ='mill',      weight={medieval=2}, pervillage=1},
	{scm="hut_1",           yoff= 0, orients={0}, farming_plus=0, avoid='', typ='hut',       weight={medieval=1}},
	{scm="farm_full_1",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_full_2",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_full_3",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_full_4",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_full_5",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_full_6",     yoff= 0, orients={0}, farming_plus=0, avoid='', typ='farm_full', weight={medieval=1/4}},
	{scm="farm_tiny_1",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_2",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_3",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_4",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_5",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_6",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="farm_tiny_7",     yoff= 0, orients={0}, farming_plus=1, avoid='', typ='farm_tiny', weight={medieval=1}},
	{scm="taverne_1",       yoff= 0, orients={0}, farming_plus=1, avoid='', typ='tavern',    weight={medieval=1/2}},
	{scm="taverne_2",       yoff= 0, orients={0}, farming_plus=0, avoid='', typ='tavern',    weight={medieval=1/2}},
	{scm="taverne_3",       yoff= 0, orients={0}, farming_plus=0, avoid='', typ='tavern',    weight={medieval=1/2}},
	{scm="taverne_4",       yoff= 0, orients={0}, farming_plus=0, avoid='', typ='tavern',    weight={medieval=1/2}},

	{scm="well_1",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_2",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_3",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_4",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_5",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_6",          yoff= 0, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_7",          yoff= -1, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},
	{scm="well_8",          yoff= -1, orients={0}, farming_plus=0, avoid='well', typ='well',  weight={medieval=1/12}},

	{scm="tree_place_1",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_2",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_3",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_4",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_5",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_6",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_7",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_8",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_9",    yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},
	{scm="tree_place_10",   yoff= 1, orients={0}, farming_plus=0, avoid='', typ='village_square', weight={medieval=1/12}, pervillage=1},

	{scm="wagon_1",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_2",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_3",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_4",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_5",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_6",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_7",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_8",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_9",         yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_10",        yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_11",        yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},
	{scm="wagon_12",        yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='wagon',  weight={medieval=1/12}},

	{scm="bench_1",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='bench',  weight={medieval=1/12}},
	{scm="bench_2",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='bench',  weight={medieval=1/12}},
	{scm="bench_3",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='bench',  weight={medieval=1/12}},
	{scm="bench_4",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='bench',  weight={medieval=1/12}},

	{scm="shed_1",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_2",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_3",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_5",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_6",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_7",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_8",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_9",          yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_10",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_11",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},
	{scm="shed_12",         yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='shed',  weight={medieval=1/10}},

	-- hut and hills for charachoal burners; perhaps they could live together with lumberjacks?
	{scm="charachoal_hut",  yoff= 0, orients={0,1,2}, farming_plus=0, avoid='', typ='hut',  weight={charachoal=1}},
	{scm="charachoal_hill", yoff= 0, orients={0,1,2,3}, farming_plus=0, avoid='', typ='hut',  weight={charachoal=1}},

	-- lumberjacks; they require the cottages mod
	{scm="lumberjack_1",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_2",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_3",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_4",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_5",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_6",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_7",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_8",        yoff= 1, orients={1}, avoid='', typ='lumberjack', weight={lumberjack=1}},
	{scm="lumberjack_pub_1",    yoff= 1, orients={1}, avoid='', typ='tavern',     weight={lumberjack=3}, pervillage=1},
	{scm="lumberjack_church_1", yoff= 1, orients={1}, avoid='', typ='church',     weight={lumberjack=3}, pervillage=1},
	{scm="lumberjack_hotel_1",  yoff= 1, orients={1}, avoid='', typ='house',      weight={lumberjack=1},},

--[[
	{scm="cow_trader_1",    yoff= 0, orients={4}, avoid='', typ='trader',     weight={lumberjack=1}},

	-- clay traders depend on cottages as well
	{scm="trader_clay_1",   yoff= 0, orients={4}, avoid='', typ='trader',     weight={claytrader=1}},
	{scm="trader_clay_2",   yoff= 0, orients={4}, avoid='', typ='trader',     weight={claytrader=1}},
	{scm="trader_clay_3",   yoff= 0, orients={4}, avoid='', typ='trader',     weight={claytrader=1}},
	{scm="trader_clay_4",   yoff= 0, orients={4}, avoid='', typ='trader',     weight={claytrader=1}},
	{scm="trader_clay_5",   yoff= 0, orients={4}, avoid='', typ='trader',     weight={claytrader=1}},
--]]

   -- Houses from Taokis Structure I/O Mod (see https://forum.minetest.net/viewtopic.php?id=5524)

	{scm="default_town_farm",          yoff= -1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_house_large_1", yoff= -4, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/4}},
	{scm="default_town_house_large_2", yoff= -4, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/4}},
	{scm="default_town_house_medium",  yoff= -4, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/2}},
	{scm="default_town_house_small",   yoff= -4, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_house_tiny_1",  yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_house_tiny_2",  yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_house_tiny_3",  yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_park",          yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1}},
	{scm="default_town_tower",         yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/6}},
	{scm="default_town_well",          yoff= -6, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/4}},
	{scm="default_town_fountain",      yoff=  1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/4}},
	-- the hotel seems to be only the middle section of the building; it's build for another spawning algorithm
--	{scm="default_town_hotel",         yoff= -1, orients={1}, farming_plus=0, avoid='',     typ='house',  weight={taoki=1/5}},

   -- include houses from LadyMacBeth, originally created for Mauvebics mm2 modpack; the houses seem to be in canadian village style
	{scm="c_bank",                     yoff=  1, orients={2}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}},
	{scm="c_bank2",                    yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}},
	{scm="c_bar",                      yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}},
	{scm="c_hotel",                    yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}},
	{scm="c_postoffice",               yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="c_bordello",                 yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="c_library",                  yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},

	{scm="g_observatory",              yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="g_court",                    yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="g_prefecture",               yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="g_townhall",                 yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=1}, pervillage=1},
	{scm="g_park2",                    yoff= -1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=2},},

	{scm="r_apartments",               yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=4},},
	{scm="r_rowhouses",                yoff=  1, orients={2}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=4},},
	{scm="r_manorhouse",               yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=3},},
	{scm="r_triplex",                  yoff=  1, orients={0}, farming_plus=0, avoid='',     typ='ladymacbeth',  weight={canadian=3},},
}


-- the schematics for buildings of type 'farm_tiny' grow cotton; the farming_plus fruits would be far more fitting
mg_fruit_list = {'carrot','potatoe','orange','rhubarb','strawberry','tomato','cotton'};
-- is farming_plus available? If not, we can't use this
if( not( minetest.get_modpath("farming_plus"))) then
	mg_fruit_list = nil;
end

-- 'nore' and 'taoki' do not require any other mods; thus, they can be used in all worlds
mg_village_types = { 'nore', 'taoki'};

if(         minetest.get_modpath("cottages")) then
	table.insert( mg_village_types, 'medieval' );
	table.insert( mg_village_types, 'charachoal' );
	table.insert( mg_village_types, 'lumberjack' );
--	table.insert( mg_village_types, 'claytrader' );  TODO

	if( minetest.get_modpath("glasspanes")) then
		table.insert( mg_village_types, 'logcabin' );
	end
end

if( minetest.get_modpath( 'hdb' ) and minetest.get_modpath( 'nbu' )) then
	table.insert( mg_village_types, 'canadian' );
end

--mg_village_types = {'lumberjack'};
-- TODO: handle grasshut

-- read the data files and fill in information like size and nodes that need on_construct to be called after placing
mg_buildings_init = function()

	local mts_path = minetest.get_modpath("mg").."/schems/";
	-- determine the size of the given houses
	for i,v in ipairs( buildings ) do
     

		-- read the size of the building
		local res  = handle_schematics.analyze_mts_file( mts_path..buildings[ i ].scm ); 
		-- alternatively, read the mts file
		if( not( res )) then
			res = import_scm( buildings[ i ].scm );
		end

		-- provided the file could be analyzed successfully
		if( res and res.size and res.size.x ) then
			-- the file has to be placed with minetest.place_schematic(...)
			buildings[ i ].is_mts = 1;

			buildings[ i ].sizex = res.size.x;
				buildings[ i ].sizez = res.size.z;
			buildings[ i ].ysize = res.size.y;
			
			-- some buildings may be rotated
			if(   res.rotated == 90
			  or  res.rotated == 270 ) then

				buildings[ i ].sizex = res.size.z;
				buildings[ i ].sizez = res.size.x;
			end

			if( not( buildings[ i ].yoff ) or buildings[ i ].yoff == 0 ) then
				buildings[ i ].yoff = res.burried;
			end

			-- we do need at least the list of nodenames which will need on_constr later on
			buildings[ i ].rotated          = res.rotated;
			buildings[ i ].nodenames        = res.nodenames;
			buildings[ i ].on_constr        = res.on_constr;
			buildings[ i ].after_place_node = res.after_place_node;

		-- determine size of worldedit schematics
		elseif( res and #res and #res[1] and #res[1][1]) then

			-- scm has the following structure: scm[y][x][z] 
			buildings[ i ].ysize = #res;
			buildings[ i ].sizex = #res[1];
			buildings[ i ].sizez = #res[1][1];

			buildings[ i ].is_mts = 0;

			-- deep copy the schematics data here so that the file does not have to be read again
			-- caching cannot be done here as not all nodes from other mods have been registered yet!
			--buildings[ i ].scm_data_cache = minetest.serialize( res );

		-- missing data regarding building size - do not use this building for anything
		elseif( not( buildings[ i ].sizex )    or not( buildings[ i ].sizez )
			or   buildings[ i ].sizex == 0 or      buildings[ i ].sizez==0) then

			-- no village will use it
			buildings[ i ].weight = {};

		else
			-- the file has to be handled by worldedit; it is no .mts file
			buildings[ i ].is_mts = 0;
		end
		-- print it for debugging usage
   		--print( v.scm .. ': '..tostring(buildings[i].sizex)..' x '..tostring(buildings[i].sizez)..' x '..tostring(buildings[i].ysize)..' h');
	end
end


-- call the initialization function above
mg_buildings_init();


--local gravel = minetest.get_content_id("default:gravel")
local gravel = minetest.get_content_id("default:gravel")
local rgravel = {}
for i = 1, 2000 do
	rgravel[i] = gravel
end
local rgravel2 = {}
for i = 1, 2000 do
	rgravel2[i] = rgravel
end
local rair = {}
for i = 1, 2000 do
	rair[i] = c_air
end
local rair2 = {}
for i = 1, 2000 do
	rair2[i] = rair
end
local road_scm = {rgravel2, rair2}
buildings["road"] = {yoff = 0, ysize = 2, scm = road_scm}

local rwall = {{minetest.get_content_id("default:stonebrick")}}
local wall = {}
for i = 1, 6 do
	wall[i] = rwall
end
buildings["wall"] = {yoff = 1, ysize = 6, scm = wall}


--local total_weight = 0
--for _, i in ipairs(buildings) do
--	if i.weight == nil then i.weight = 1 end
--	total_weight = total_weight+i.weight
--	i.max_weight = total_weight
--end
--local multiplier = 3000/total_weight
--for _,i in ipairs(buildings) do
--	i.max_weight = i.max_weight*multiplier
--end


for j,v in ipairs( mg_village_types ) do
	
	local total_weight = 0
	for _, i in ipairs(buildings) do
		if( not( i.max_weight )) then
			i.max_weight = {};
		end
		if( i.weight and i.weight[ v ] and i.weight[ v ]>0 ) then
			total_weight = total_weight+i.weight[ v ]
			i.max_weight[v] = total_weight
		end
	end
	local multiplier = 3000/total_weight
	for _,i in ipairs(buildings) do
		if( i.weight and i.weight[ v ] and i.weight[ v ]>0 ) then
			i.max_weight[v] = i.max_weight[ v ]*multiplier
		end
	end
end
