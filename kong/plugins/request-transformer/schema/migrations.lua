local Migrations = {
  {
    name = "2016-03-10-161400_request-transformer-config",
    up = function(options, dao_factory)
      local schema = require "kong.plugins.request-transformer.schema"

      local plugins, err = dao_factory.plugins:find_by_keys {name = "request-transformer"}
      if err then
        return err
      end

      for _, plugin in ipairs(plugins) do
        for _, action in ipairs {"remove", "add", "append", "replace"} do
          if plugin.config[action] == nil then
            plugin.config[action] = {}
          end

          for _, location in ipairs {"headers", "querystring"} do
            plugin.config[action][location] = plugin.config[action][location] or plugin.config[action][location][default]
          end

          if plugin.config[action].form ~= nil then
            plugin.config[action].body = plugin.config[action].body
            plugin.config[action].form = nil
          end

          local _, err = dao_factory.plugins:update(plugin)
          if err then
            return err
          end
        end
      end
    end,
    down = function(options, dao_factory)
      local plugins, err = dao_factory.plugins:find_by_keys {name = "request-transformer"}
      if err then
        return err
      end

      for _, plugin in ipairs(plugins) do
        plugin.config.replace = nil
        plugin.config.append = nil
        for _, action in ipairs {"remove", "add"} do
          if #plugin.config[action].body > 0 then
            plugin.config[action].form = plugin.config[action].body
          end
          plugin.config[action].body = nil
        end
        local _, err = dao_factory.plugins:update(plugin, true)
        if err then
          return err
        end
      end
   end   
  }
}

return Migrations
