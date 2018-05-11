Pod::Spec.new do |s|

  s.name         = "SecureStorage"
  s.version      = "1.0.0"
  s.summary      = "A simple utility to store objects securely on disk or in defaults"
  s.description  = "A simple library that allows applications to store Objective-C/Swift objects securely on disk or in user defaults."
  s.homepage     = "https://github.com/Ad1991/SecureStorage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adarsh Rai" => "adrai75@gmail.com" }
  
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/Ad1991/SecureStorage.git", :tag => "#{s.version}" }
  s.source_files  = "SecureStorage/**/*.{h,m,swift}"

  s.requires_arc = true
  s.preserve_paths = ['SecureStorage/**/*']
  s.swift_version = '4.1'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]' => '$(PODS_ROOT)/SecureStorage/SecureStorage/modulemaps/iphoneos',
                            'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]' => '$(PODS_ROOT)/SecureStorage/SecureStorage/modulemaps/iphonesimulator',
                            'SWIFT_VERSION' => '4.1'}

end
