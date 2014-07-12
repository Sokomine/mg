
-- TODO: save and restore ought to be library functions and not implemented in each individual mod!
mg.save_data = function()

   local data = minetest.serialize( mg.mg_all_villages );
   local path = minetest.get_worldpath().."/mg_all_villages.data";

   local file = io.open( path, "w" );
   if( file ) then
      file:write( data );
      file:close();
   else
      print("[Mod mg] Error: Savefile '"..tostring( path ).."' could not be written.");
   end
end


mg.restore_data = function()

   local path = minetest.get_worldpath().."/mg_all_villages.data";

   local file = io.open( path, "r" );
   if( file ) then
      local data = file:read("*all");
      mg.mg_all_villages = minetest.deserialize( data );
      file:close();
   else
      print("[Mod mg] Error: Savefile '"..tostring( path ).."' not found.");
   end
end
