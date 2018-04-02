Pod::Spec.new do |s|

  s.name         = "SecureStorage"
  s.version      = "0.1.0"
  s.summary      = "A simple utility to store objects securely on disk or in defaults"
  s.description  = "A simple library that allows applications to store Objective-C/Swift objects securely on disk or in user defaults."
  s.homepage     = "https://github.com/Ad1991/SecureStorage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adarsh Rai" => "adrai75@gmail.com" }
  
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/Ad1991/SecureStorage.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "SecureStorage/**/*.{h,m,swift,modulemap}"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  s.requires_arc = true

  s.xcconfig = {  "MODULEMAP_FILE[sdk=iphoneos*]" => "$(SDKROOT)/SecureStorage/iphoneos.modulemap",
                  "MODULEMAP_FILE[sdk=iphonesimulator*]" => "$(SDKROOT)/SecureStorage/iphonesimulator.modulemap" }

end
