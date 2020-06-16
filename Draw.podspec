Pod::Spec.new do |s|
  s.name             = 'Draw'
  s.version          = '0.2.4'
  s.summary          = 'Drawing library for Apple platform.'

  s.description      = <<-DESC
Drawing library for Apple platform. Can be used as a backport of PencilKit.
                       DESC

  s.homepage         = 'https://github.com/horita-yuya/Draw'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'horita-yuya' => 'horitayuya@gmail.com' }
  s.source           = { :git => 'https://github.com/horita-yuya/Draw.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/horita_yuya'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Draw/**/*.swift'
end
