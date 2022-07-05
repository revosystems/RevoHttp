# EXAMPLE / TUTORIAL: https://www.raywenderlich.com/5823-how-to-create-a-cocoapod-in-swift

Pod::Spec.new do |spec|

  spec.name         = "RevoHttp"
  spec.version      = "0.3.2"
  spec.summary      = "Foundation http."

  spec.description  = "A wrapper arround native Http requests for simpler and cleaner code"

  spec.homepage     = "https://revo.works"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.swift_version = "5.0"


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "Jordi Puigdellívol" => "jordi@gloobus.net" }
  # Or just: spec.author    = "Jordi Puigdellívol"
  # spec.authors            = { "Jordi Puigdellívol" => "jordi@gloobus.net" }
  spec.social_media_url   = "https://instagram.com/badchoice2"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # spec.platform     = :ios
   #spec.platform     = :ios, "9.3"

  #  When using multiple platforms
   spec.ios.deployment_target = "13.0"
  # spec.osx.deployment_target = "13.0"
  # spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "13.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/revosystems/revohttp.git", :tag => "0.3.2" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "RevoHttp/src/**/*.{swift}"#, "src/**/*.{h,m}"
  #spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
   spec.dependency "RevoFoundation", "~> 0.2.0"

end
