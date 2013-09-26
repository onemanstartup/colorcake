module Colorcake
  class Engine < Rails::Engine
    engine_name :colorcake
    config.autoload_paths += Dir["#{config.root}/app/models/concerns/"]
  end
end
