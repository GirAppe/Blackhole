# Andrzej Michnia @ GirAppe Studio

Pod::Spec.new do |s|
  s.name             = 'Blackhole'
  s.version          = '1.0.1'
  s.summary          = 'A delightful iOS to watchOS communication framework.'

  s.description      = <<-DESC
  A delightful iOS to watchOS communication framework, based on WatchConnectivity framework's WCSession.

  Utilizes Wormhole concept, that simplifies data sync between iOS and watch devices. Also, provides set of handful protocols, allowing to create easily synchronized custom model classes.

  Some of the features:
   - start listeners, waiting for given communication message identifiers
   - send simple messages
   - send every object, that can be represented as Data
   - request any object from counterpart app, be sending a message and specifying success handler
   - all public api wrapped in convenient promises implementation (BrightFutures)

  Must to have for watchOS development.
                       DESC

  s.homepage         = 'https://github.com/GirAppe/Blackhole'
  s.screenshots      = 'https://raw.githubusercontent.com/GirAppe/Blackhole/develop/Icon-60%402x.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrzej Michnia' => 'amichnia@girappe.com' }
  s.source           = { :git => 'https://github.com/GirAppe/Blackhole.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'

  s.frameworks = 'Foundation', 'WatchConnectivity'
  s.default_subspec = "Core"

  s.subspec 'Core' do |core|
      core.source_files     = 'Blackhole/Classes/Core/**/*'
  end

  s.subspec 'BrightFutures' do |futures|
      futures.source_files  = 'Blackhole/Classes/{Core,BrightFutures}/**/*'
      futures.dependency      'BrightFutures', '~> 5.0.1'
  end

end
