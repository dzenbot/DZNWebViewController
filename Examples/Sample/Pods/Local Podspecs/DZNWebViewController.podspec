
@version = "3.1"

Pod::Spec.new do |s|
  s.name           = "DZNWebViewController"
  s.version        = @version
  s.summary        = "An iPhone/iPad mini WebKit browser controller, useful for in-app web browsing experience."
  s.homepage       = "https://github.com/dzenbot/DZNWebViewController"
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { "Ignacio Romero Z." => "iromero@dzen.cl" }
  s.source         = { :git => "https://github.com/dzenbot/DZNWebViewController.git", :tag => "v#{s.version}" }

  s.platform       = :ios, '8.0'
  s.requires_arc   = true

  s.source_files   = 'Source/Classes/*.{h,m}'
  s.resources      = 'Source/Resources/*.*'
  s.framework      = 'UIKit', 'WebKit'
end