Pod::Spec.new do |s|
  s.name             = 'rutube_webview'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for RuTube WebView.'
  s.description      = <<-DESC
A Flutter plugin that provides WebView with fullscreen video support.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
