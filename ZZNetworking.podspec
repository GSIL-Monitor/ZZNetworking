Pod::Spec.new do |s|
    s.name             = 'ZZNetworking'
    s.version          = '0.1.0'
    s.summary          = 'A short description of ZZNetworking.'
    s.description      = <<-DESC
                        自己练习网络库封装
                        DESC

    s.homepage         = 'https://github.com/zhangrenfeng/ZZNetworking'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'zhangrenfeng' => 'zhangrenfeng@bytedance.com' }
    s.source           = { :git => 'https://github.com/zhangrenfeng/ZZNetworking.git', :tag => s.version.to_s }

    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.source_files = 'ZZNetworking/**/*.{h,m,mm,c}'
    s.public_header_files = "ZZNetworking/**/*.{h, hpp}"

    s.ios.exclude_files = "ZZNetworking/Implementation/Chromium/includes/**/*.h"

    s.ios.frameworks = 'CFNetwork', 'MobileCoreServices', 'SystemConfiguration'

    s.preserve_paths = "ZZNetworking/Implementation/Chromium/includes/*", "ZZNetworking/Implementation/Chromium/libs/*", "ZZNetworking/Implementation/Chromium/*.jar"

    # 指定外部静态库
    s.ios.vendored_libraries = "ZZNetworking/Implementation/Chromium/libs/libbase.a","ZZNetworking/Implementation/Chromium/libs/libbase_static.a","ZZNetworking/Implementation/Chromium/libs/libboringssl.a","ZZNetworking/Implementation/Chromium/libs/libchrome_zlib.a","ZZNetworking/Implementation/Chromium/libs/libcrcrypto.a" "ZZNetworking/Implementation/Chromium/libs/libcronet.a","ZZNetworking/Implementation/Chromium/libs/libdynamic_annotations.a","ZZNetworking/Implementation/Chromium/libs/libmodp_b64.a","ZZNetworking/Implementation/Chromium/libs/libnet.a","ZZNetworking/Implementation/Chromium/libs/libproto.a" "ZZNetworking/Implementation/Chromium/libs/libprotobuf_lite.a","ZZNetworking/Implementation/Chromium/libs/libsdch.a","ZZNetworking/Implementation/Chromium/libs/liburl.a","ZZNetworking/Implementation/Chromium/libs/libzlib_x86_simd.a" ,"ZZNetworking/Implementation/Chromium/libs/libmetrics.a"

    s.libraries = "c++","base","base_static","boringssl", "chrome_zlib","crcrypto","cronet","dynamic_annotations" ,"modp_b64", "net","proto","sdch", "url", "zlib_x86_simd", "metrics","resolv"

    # 修改编译选项
    s.pod_target_xcconfig = {'USER_HEADER_SEARCH_PATHS' => '${PODS_ROOT}/ZZNetworking/ZZNetworking/Implementation/Chromium/includes', 'GCC_ENABLE_CPP_RTTI' => 'NO'}

    s.libraries = "c++","base","base_static","boringssl", "chrome_zlib","crcrypto","cronet","dynamic_annotations" ,"modp_b64", "net","proto","protobuf_lite","sdch", "url", "zlib_x86_simd", "metrics","resolv"

    s.dependency 'AFNetworking', '~> 3.1.0'

    s.prepare_command = 'sh ./ZZNetworking/Implementation/Chromium/getLib.sh'
end

