
-- reserve namespace for the villages
mg_villages = {}

mg_villages.all_villages  = {}
mg_villages.mg_generated_map = {}
mg_villages.anz_villages = 0;

dofile(minetest.get_modpath(minetest.get_current_modname()).."/save_restore.lua")
mg_villages.all_villages     = save_restore.restore_data( 'mg_all_villages.data' ); -- read mg_villages.all_villages data saved for this world from previous runs
mg_villages.mg_generated_map = save_restore.restore_data( 'mg_generated_map.data' );

dofile(minetest.get_modpath(minetest.get_current_modname()).."/we.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/rotate.lua")

-- read size from schematics files directly
-- analyze_mts_file.lua uses handle_schematics.* namespace
dofile(minetest.get_modpath(minetest.get_current_modname()).."/analyze_mts_file.lua") 

-- Note: the "buildings" talbe is not in the mg_villages.* namespace
dofile(minetest.get_modpath(minetest.get_current_modname()).."/buildings.lua")

-- replace some materials for entire villages randomly
dofile(minetest.get_modpath(minetest.get_current_modname()).."/replacements.lua")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/villages.lua")

-- adds a command that allows to teleport to a known village
dofile(minetest.get_modpath(minetest.get_current_modname()).."/chat_commands.lua")
-- protect villages from griefing
dofile(minetest.get_modpath(minetest.get_current_modname()).."/protection.lua")
-- create and show a map of the world
dofile(minetest.get_modpath(minetest.get_current_modname()).."/map_of_world.lua")
