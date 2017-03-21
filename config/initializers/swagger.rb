class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distiction between the APIs and the API documentation paths
    "apidocs/#{path}"
  end
end

Swagger::Docs::Config.register_apis({
  '0.0' => {
    controller_base_path: '',
    api_file_path: 'public/apidocs',
    base_path: 'http://localhost:3000',
    clean_directory: true,
    api_extention_type: :json
  }
})
