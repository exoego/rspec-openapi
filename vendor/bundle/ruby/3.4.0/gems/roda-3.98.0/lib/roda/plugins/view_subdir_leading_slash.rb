# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The view_subdir_leading_slash plugin builds on the view_options
    # plugin, and changes the behavior so that if a view subdir is set,
    # it is used for all templates, unless the template starts with a
    # leading slash:
    #
    #   plugin :view_subdir_leading_slash
    #
    #   route do |r|
    #     r.on "users" do
    #       set_view_subdir 'users'
    #       
    #       r.get 'list' do
    #         view 'lists/users' # uses ./views/users/lists/users.erb
    #       end
    #
    #       r.get 'list' do
    #         view '/lists/users' # uses ./views//lists/users.erb
    #       end
    #     end
    #   end
    #
    # The default for the view_options plugin is to not use a
    # view subdir if the template name contains a slash at all.
    module ViewSubdirLeadingSlash
      # Load the view_options plugin before this plugin, since this plugin
      # works by overriding a method in the view_options plugin.
      def self.load_dependencies(app)
        app.plugin :view_options
      end

      module InstanceMethods
        private

        # Use a view subdir unless the template starts with a slash.
        def use_view_subdir_for_template_name?(name)
          !name.start_with?('/')
        end
      end
    end

    register_plugin(:view_subdir_leading_slash, ViewSubdirLeadingSlash)
  end
end

