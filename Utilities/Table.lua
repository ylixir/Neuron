-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}

local Table; Table = {
  --- create a new table by merging two or more tables
  --
  -- it returns a function instead of a table to enable
  -- syntax sugar like: Table.spread{a=1}{b=2}
  -- or just a function call like: Table.spread(table1, table2, table3)
  -- based on code from https://hiphish.github.io/blog/2020/12/31/spreading-tables-in-lua
  --
  -- table -> ... -> table -> (table -> table )
  -- @param table the base table(s)
  -- @return a function that takes a second table and spreads it over the first
  spread = function (...)
    local tables = {...}
    local result = {}
    for _,t in ipairs(tables) do
      for k,v in pairs(t) do
        result[k]=v
      end
    end

    -- note that the base tables are copied _before_ the curry,
    -- not when the function is applied
    return #tables > 1 and result or function(top)
      for k,v in pairs(top) do
        result[k]=v
      end
      return result
    end
  end,
}

addonTable.utilities.Table = Table
