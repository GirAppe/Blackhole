#
# Be sure to run `pod lib lint Blackhole.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Blackhole'
  s.version          = '0.1.1'
  s.summary          = 'iOS <-> watchOS communication framework, based on WatchConnectivity framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

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
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Blackhole/Classes/Core/**/*'

  # s.resource_bundles = {
  #   'Blackhole' => ['Blackhole/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation', 'WatchConnectivity'
  # s.dependency 'AFNetworking', '~> 2.3'



end
