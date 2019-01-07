Pod::Spec.new do |s|


  s.name         = "DKRequest"
  s.version      = "0.0.1"
  s.summary      = "networking"


  s.homepage     = "https://github.com/MjzDk/DKRequest.git"

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "dangkai" => "15929996560@163.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/MjzDk/DKRequest.git", :tag => "#{s.version}" }

  s.source_files = "DKRequest/**/*.{h,m}"


  s.requires_arc = true
  s.dependency "AFNetworking"
  s.dependency "YYCache"
  s.dependency "YYCategories"
  s.dependency "YYModel"
end