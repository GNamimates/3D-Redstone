local json = require('json')

local function readFile(path)
   local f = assert(io.open(path, "rb"))
   local data = f:read('*all')
   f:close()
   return data
end
local function writeFile(path, data)
   local f = assert(io.open(path, "wb"))
   f:write(data)
   f:close()
end

local blockstates = json.decode(readFile('blockstate_orginal.json'))

local multipart = {
   -- dot
   {
      when = {
         north = "none",
         east = "none",
         south = "none",
         west = "none",
      },
      apply = {
         model = "minecraft:redstone/template_power_dot"
      }
   },
   -- curve
   {
      when = {
         north = "none",
         east = "side",
         south = "side",
         west = "none",
      },
      apply = {
         model = "minecraft:redstone/template_power_curve",
         y = 180
      }
   },
   {
      when = {
         north = "side",
         east = "none",
         south = "none",
         west = "side",
      },
      apply = {
         model = "minecraft:redstone/template_power_curve"
      }
   },
   {
      when = {
         north = "side",
         east = "side",
         south = "none",
         west = "none",
      },
      apply = {
         model = "minecraft:redstone/template_power_curve",
         y = 90
      }
   },
   {
      when = {
         north = "none",
         east = "none",
         south = "side",
         west = "side",
      },
      apply = {
         model = "minecraft:redstone/template_power_curve",
         y = 270
      }
   },
   -- line
   {
      when = {
         OR = {
            {
               north = "none",
               east = "side",
               south = "none",
               west = "side",
            },
            {
               north = "side",
               east = "none",
               south = "side",
               west = "none",
            },
            {
               north = "side",
               east = "side",
               south = "side",
               west = "side",
            },
            {
               north = "none",
               east = "side",
               south = "side",
               west = "side",
            },
            {
               north = "side",
               east = "none",
               south = "side",
               west = "side",
            },
            {
               north = "side",
               east = "side",
               south = "none",
               west = "side",
            },
            {
               north = "side",
               east = "side",
               south = "side",
               west = "none",
            }
         }
      },
      apply = {
         model = "minecraft:redstone/template_power_line"
      }
   },
   -- vertical
   {
      when = {
         AND = {
            {north = 'up'},
            { OR = { {south = 'none'}, {south = 'side'} } },
            { OR = { {east = 'none'}, {east = 'side'} } },
            { OR = { {west = 'none'}, {west = 'side'} } },
         }
      },
      apply = {
         model = 'minecraft:redstone/template_power_line_down',
      }
   },
   {
      when = {
         AND = {
            { OR = { {north = 'none'}, {north = 'side'} } },
            {south = 'up'},
            { OR = { {east = 'none'}, {east = 'side'} } },
            { OR = { {west = 'none'}, {west = 'side'} } },
         }
      },
      apply = {
         model = 'minecraft:redstone/template_power_line_down',
         y = 180,
      }
   },
   {
      when = {
         AND = {
            { OR = { {north = 'none'}, {north = 'side'} } },
            { OR = { {south = 'none'}, {south = 'side'} } },
            {east = 'up'},
            { OR = { {west = 'none'}, {west = 'side'} } },
         }
      },
      apply = {
         model = 'minecraft:redstone/template_power_line_down',
         y = 90,
      }
   },
   {
      when = {
         AND = {
            { OR = { {north = 'none'}, {north = 'side'} } },
            { OR = { {south = 'none'}, {south = 'side'} } },
            { OR = { {east = 'none'}, {east = 'side'} } },
            {west = 'up'},
         }
      },
      apply = {
         model = 'minecraft:redstone/template_power_line_down',
         y = 270,
      }
   },
   -- vertical middle
   {
      when = {
         OR = {
            {north = 'up', south = 'up'},
            {east = 'up', west = 'up'},
            {north = 'up', east = 'up'},
            {east = 'up', south = 'up'},
            {south = 'up', west = 'up'},
            {west = 'up', north = 'up'},
         }
      },
      apply = {
         model = 'minecraft:redstone/template_power_middle'
      }
   }
}

local filesToWrite = {}
for _, v in pairs(multipart) do
   for i = 1, 15 do -- 0 is invisible for the clean look
      local modelName = v.apply.model:gsub('^minecraft:redstone/template_', '')..'_level_'..i
      filesToWrite[
         './../assets/minecraft/models/redstone/'..modelName..'.json'
      ] = json.encode{
         parent = v.apply.model,
         textures = {
               ["0"] = "redstone/dust_redstone_level_"..i
         }
      }
      table.insert(
         blockstates.multipart,
         {
            when = {
               AND = {
                  v.when,
                  {
                     power = i
                  }
               }
            },
            apply = {
               model = 'minecraft:redstone/'..modelName,
               y = v.apply.y
            }
         }
      )
   end
end

for i, v in pairs(filesToWrite) do
   writeFile(i, v)
end


writeFile('./../assets/minecraft/blockstates/redstone_wire.json', json.encode(blockstates))