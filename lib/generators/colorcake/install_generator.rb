module Colorcake
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc "This generator creates an initializer file at config/initializers"

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      # copy configuration
      def copy_initializer
        template "colorcake.rb", "config/initializers/colorcake.rb"
      end
    end
  end
end
