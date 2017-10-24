Pod::Spec.new do |s|
  s.name             = 'Kogatana'
  s.version          = '0.1.0'
  s.summary          = 'Debug Logger By USB Hub / Wi-Fi.'
  s.homepage         = 'https://github.com/josephwoo/Kogatana'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Joenan' => 'josephwoo16@gmail.com' }
  s.source           = { :git => 'git@github.com:josephwoo/Kogatana.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.requires_arc = true
  s.source_files = 'Kogatana/**/**/*.{h,m}'
  s.public_header_files = 'Kogatana/**/Public/*.h'

  s.subspec 'iOS' do |ss|
    ss.source_files = 'Kogatana/{iOS,Base}/**/*.{h,m}'
    ss.public_header_files = 'Kogatana/{iOS,Base}/Public/*.h'
  end

  s.subspec 'OSX' do |ss|
    ss.source_files = 'Kogatana/{OSX,Base}/**/*.{h,m}'
    ss.public_header_files = 'Kogatana/{OSX,Base}/Public/*.h'
  end

end
