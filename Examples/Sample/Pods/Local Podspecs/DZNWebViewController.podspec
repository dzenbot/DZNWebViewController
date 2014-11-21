
@version = "2.0"

Pod::Spec.new do |s|
  s.name           = "DZNWebViewController"
  s.version        = @version
  s.summary        = "A very simple web browser with useful navigation and export tools."
  s.homepage       = "https://github.com/dzenbot/DZNWebViewController"
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { "Ignacio Romero Z." => "iromero@dzen.cl" }
  s.source         = { :git => "https://github.com/dzenbot/DZNWebViewController.git", :tag => "v#{s.version}" }

  s.platform       = :ios, "7.0"
  s.requires_arc   = true

  s.source_files   = 'Classes', 'Source/Classes/**/*.*'
  s.resources      = ["Source/Resources/*.*", "Source/Scripts/*.js"]
  s.framework      = 'UIKit', 'WebKit'
end