# TODO: is it necessary to keep this modularity? How different is reloading in Rails 4?

module ActiveAdmin

  module Reloader

    # Builds the proper Reloader implementation class given the
    # current version of Rails.
    #
    # @param [Rails::Application] rails_app The current rails application
    # @param [ActiveAdmin::Application] active_admin_app The current Active Admin app
    # @param [String] rails_version The version of Rails we're using.
    #
    # @returns A concrete subclass of AbstractReloader
    def self.build(rails_app, active_admin_app, rails_version)
      reloader_class = rails_version.to_f >= 3.2 ? Rails32Reloader : raise('wat')
      reloader_class.new(rails_app, active_admin_app, rails_version)
    end

    class AbstractReloader

      attr_reader :active_admin_app, :rails_app, :rails_version

      def initialize(rails_app, active_admin_app, rails_version)
        @rails_app = rails_app
        @active_admin_app = active_admin_app
        @rails_version = rails_version.to_s
      end

      def attach!
        raise "Please implement #{self.class}#attach!"
      end

      def reload!
        active_admin_app.unload!
        rails_app.reload_routes!
      end

      def major_rails_version
        @rails_version[0..2]
      end

    end

    # Reloads the application when using Rails 3.2
    #
    # 3.2 introduced a to_prepare block that only gets called when
    # files have actually changed. ActiveAdmin had built this functionality
    # in to speed up applications. So in Rails >= 3.2, we can now piggy
    # back off the existing reloader. This simplifies our duties... which is
    # nice.
    class Rails32Reloader < AbstractReloader
      # Attach to Rails and perform the reload on each request.
      def attach!
        active_admin_app.load_paths.each do |path|
          rails_app.config.watchable_dirs[path] = [:rb]
        end

        reloader = self

        ActionDispatch::Reloader.to_prepare do
          reloader.reload!
        end
      end
    end

  end
end
