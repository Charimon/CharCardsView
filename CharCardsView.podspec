Pod::Spec.new do |s| 
  s.name = 'CharCardsView'
  s.version = '0.5.2'
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.prefix_header_file = 'CharCardsView/CharCardsView-Prefix.pch'
  s.source_files = 'CharCardsView/lib/*.{h,m,c}'
  s.requires_arc = true
end
