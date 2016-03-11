local Migrations = {
  {
    name = "2016-03-10-161400_response-transformer-config",
    up = function(options, dao_factory)
      local schema = require "kong.plugins.response-transformer.schema"

      local plugins, err = dao_factory.plugins:find_by_keys {name = "response-transformer"}
      if err then
        return err
      end

      for _, plugin in ipairs(plugins) do
        for _, action in ipairs {"remove", "add", "append", "replace"} do

          if plugin.config[action] == nil then
            plugin.config[action] = {}
          end

          for _, location in ipairs {"json", "headers"} do
            plugin.config[action][location] = plugin.config[action][location] or {}
          end

          if plugin.config[action].form ~= nil then
            plugin.config[action].body = plugin.config[action].form
            plugin.config[action].form = nil
          end
        end
        local _, err = dao_factory.plugins:update(plugin)
        if err then
          return err
        end
      end
    end,
    down = function(options, dao_factory)
      local plugins, err = dao_factory.plugins:find_by_keys {name = "response-transformer"}
      if err then
        return err
      end

      for _, plugin in ipairs(plugins) do
        plugin.config.replace = nil
        plugin.config.append = nil
        local _, err = dao_factory.plugins:update(plugin, true)
        if err then
          return err
        end
      end
    end
  }
}

return Migrations
