Pod::Spec.new do |s|
  s.name         = 'DRTZlibStream'
  s.version      = '0.0.1'
  s.homepage     = 'https://github.com/drodriguez/DRTZlibStream'
  s.summary      = 'Streaming Zlib deflater and inflater for network communications.'
  s.authors      = { 'Daniel Rodríguez Troitiño' => 'drodrigueztroitino@yahoo.es' }
  s.source       = { :git => 'https://github.com/drodriguez/DRTZlibStream.git', :branch => 'master' }
  s.source_files = 'Classes', 'Classes/common/*.{h,m}'
  s.license      = 'MIT'
  s.library      = 'z'
  s.requires_arc = true
end
