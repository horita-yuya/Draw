Pod::Spec.new do |s|
  s.name             = 'DrawingKit'
  s.version          = '0.1.0'
  s.summary          = 'Drawing library for Apple platform.'

  s.description      = <<-DESC
Drawing library for Apple platform. Can be used as a backport of PencilKit.
                       DESC

  s.homepage         = 'https://github.com/horita-yuya/DrawingKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'horita-yuya' => 'horitayuya@gmail.com' }
  s.source           = { :git => 'https://github.com/horita-yuya/DrawingKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/horita_yuya'

  s.ios.deployment_target = '11.0'

  s.source_files = 'DrawingKit/**/*.swift'
end
