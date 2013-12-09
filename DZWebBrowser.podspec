Pod::Spec.new do |s|
  s.name     = 'DZWebBrowser'
  s.version  = '1.0'
  s.license  = 'MIT'
  s.summary  = 'Super Awesome Easy Fetching for Core Data 1!!!11!!!!1!.'
  s.homepage = 'https://github.com/liyoro/DZWebBrowser'
  s.author   = { 'Saul Mora' => 'saul@magicalpanda.com' }
  s.source   = { :git => 'https://github.com/liyoro/DZWebBrowser.git',:branch=>'develop', :tag => '1.0' }
  s.description  = ''
  s.source_files = 'DZWebBrowser/**/*.{h,m}'
  s.resource     = "DZWebBrowser/Source/default-controls.bundle"
  s.framework    = 'SystemConfiguration', 'CFNetwork', 'MessageUI', 'Social'
  s.requires_arc = true
end
