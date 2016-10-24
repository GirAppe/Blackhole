#
# Be sure to run `pod lib lint Blackhole.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Blackhole'
  s.version          = '0.1.3'
  s.summary          = 'iOS <-> watchOS communication framework, based on WatchConnectivity framework.'
  
  s.description      = <<-DESC
  iOS <-> watchOS communication framework, based on WatchConnectivity framework.

  Utilizes Wormhole concept, that simplifies data sync between iOS and watch devices. Also, provides set of handful protocols, allowing to create easily synchronized custom model classes.

  Must to have for watchOS development.
                       DESC

  s.homepage         = 'https://github.com/GirAppe/Blackhole'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrzej Michnia' => 'amichnia@girappe.com' }
  s.source           = { :git => 'https://github.com/GirAppe/Blackhole.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Blackhole/Classes/Core/**/*'

  s.frameworks = 'Foundation', 'WatchConnectivity'

end
