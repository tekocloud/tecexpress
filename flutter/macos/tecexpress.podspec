Pod::Spec.new do |s|
  s.name = 'tecexpress'
  s.version = '0.7.1'
  s.summary = 'Built-in tecexpress file integration.'
  s.description = s.summary
  s.homepage = 'https://github.com/tekocloud/tecexpress'
  s.license = { :file => '../LICENSE' }
  s.author = { 'Teko' => 'info@teko.cloud' }
  s.source = { :path => '.' }
  s.source_files = 'tecexpress/Sources/tecexpress/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'
  s.swift_version = '5.0'
end
