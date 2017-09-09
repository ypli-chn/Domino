Pod::Spec.new do |s|
s.name = 'Domino'
s.version = '1.0.0'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Domino is a communication mechanism among multi-level objects for Objective-C.'
s.homepage = 'https://github.com/ypli-chn/Domino'
s.authors = { "Yunpeng Li" => "ypli.chn@outlook.com" }
s.source = { :git => 'https://github.com/ypli-chn/Domino.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = 'Domino/*.{h,m}'
end