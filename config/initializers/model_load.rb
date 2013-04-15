if Rails.env == "development"
  Dir.glob("#{Rails.root}/app/models/**/*.rb") do |model_name|
    require_dependency model_name unless model_name == "." || model_name == ".."
  end 
end