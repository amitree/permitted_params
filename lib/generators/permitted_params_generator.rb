class PermittedParamsGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  desc "This generator adds the permmitted params initializer to config"

  def generate_permitted_params
    copy_file "permitted_params.rb", "config/initializers/permitted_params.rb"
  end
end
