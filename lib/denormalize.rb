Dir.glob(File.expand_path("denormalize/*.rb", File.dirname(__FILE__))).each do |file|
  require file
end

