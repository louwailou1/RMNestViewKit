
Pod::Spec.new do |s|


  s.name         = "RMNestViewKit"
  s.version      = "1.0"
  s.summary      = "RMNestViewKit."
  s.description  = <<-DESC
                    this is RMNestViewKit
                   DESC
  s.homepage     = "https://gitlab.com/RMNestViewKit"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "RMNestViewKit" => "RMNestViewKit@msn.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://gitlab.com/RMNestViewKit.git", :tag => s.version.to_s }
  s.source_files  = "RMNestViewKit/RMNestViewKit/**/*.{h,m,swift}"
  s.requires_arc = true

end
