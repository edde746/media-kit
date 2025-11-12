#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint media_kit_video.podspec` to validate before publishing.
#

require_relative '../common/darwin/Podspec/media_kit_utils.rb'

Pod::Spec.new do |s|
  # Setup required files
  system("make -C ../common/darwin HEADERS_DESTDIR=\"$(pwd)/Headers\"")

  # Initialize `MediaKitUtils`
  mku = MediaKitUtils.new(MediaKitUtils::Platform::IOS)

  s.name             = 'media_kit_video'
  s.version          = '0.0.1'
  s.summary          = 'Native implementation for video playback in package:media_kit'
  s.description      = <<-DESC
  Native implementation for video playback in package:media_kit.
                       DESC
  s.homepage         = 'https://github.com/media-kit/media-kit.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hitesh Kumar Saini' => 'saini123hitesh@gmail.com' }

  s.source           = { :path => '.' }
  s.platform         = :ios, '9.0'
  s.swift_version    = '5.0'
  s.dependency         'Flutter'

  if mku.libs_found
    s.dependency         'media_kit_libs_ios_video'

    # Define paths to frameworks dir
    framework_search_paths_iphoneos        = sprintf('$(PROJECT_DIR)/../.symlinks/plugins/%s/ios/Frameworks', mku.libs_package)
    framework_search_paths_iphonesimulator = sprintf('$(PROJECT_DIR)/../.symlinks/plugins/%s/ios/Frameworks', mku.libs_package)

    s.source_files        = 'Classes/plugin/**/*.swift', 'Headers/**/*.h'
    s.pod_target_xcconfig = {
      'DEFINES_MODULE'                               => 'YES',
      'GCC_WARN_INHIBIT_ALL_WARNINGS'                => 'YES',
      'GCC_PREPROCESSOR_DEFINITIONS'                 => '"$(inherited)" GL_SILENCE_DEPRECATION COREVIDEO_SILENCE_GL_DEPRECATION',
      'OTHER_LDFLAGS'                                => '"$(inherited)" -framework Mpv -framework Libavcodec -framework Libavdevice -framework Libavfilter -framework Libavformat -framework Libavutil -framework Libswresample -framework Libswscale -framework Libass -framework Libuchardet -lMoltenVK -framework Libplacebo -framework Libfreetype -framework Libfribidi -framework Libharfbuzz -framework gmp -framework Libuavs3d -framework Libshaderc_combined -framework Libunibreak -framework gnutls -framework nettle -framework hogweed -framework lcms2 -framework Libdav1d -framework Libdovi -framework Libbluray -lxml2 -lz -liconv -lbz2 -framework CoreText -framework UIKit -framework Metal -framework MetalKit -framework CoreMedia -framework VideoToolbox -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework Security -framework SystemConfiguration -framework Network',
      'LIBRARY_SEARCH_PATHS[sdk=iphoneos*]' => '"$(inherited)" "${PODS_XCFRAMEWORKS_BUILD_DIR}/media_kit_libs_ios_video"',
      'LIBRARY_SEARCH_PATHS[sdk=iphonesimulator*]' => '"$(inherited)" "${PODS_XCFRAMEWORKS_BUILD_DIR}/media_kit_libs_ios_video"',
      # Flutter.framework does not contain a i386 slice.
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    }
  else
    s.source_files        = 'Classes/stub/**/*.swift'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  end
end
