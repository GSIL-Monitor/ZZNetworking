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

    s.ios.deployment_target = '8.0'

    s.source_files = 'ZZNetworking/Classes/**/*'
    s.public_headers = "Pod/Classes/**/*.{h, hpp}"

    # s.resource_bundles = {
    #   'ZZNetworking' => ['ZZNetworking/Assets/*.png']
    # }

    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'AFNetworking', '~> 3.1.0'
end

