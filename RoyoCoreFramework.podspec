Pod::Spec.new do |s|  
    s.name              = 'RoyoCoreFramework'
    s.version           = '0.0.1'
    s.summary           = 'The core framework for royo project'
s.description      = <<-DESC
The core framework includes Location manager, login with apple, Table view and collection view datasource classes, unary prefix for unwrapping option manager, Facebook login manager
                       DESC
    s.homepage          = 'https://royoapps.com'

    s.author            = { 'CodeBrew' => 'daman1208@gmail.com' }
    s.license           = { :type => 'MIT', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :git => "https://github.com/damandeep1208/RoyoCoreFramework.git", :tag => "0.0.1" }
s.source_files = "RoyoCoreFramework/RoyoCoreFramework"
s.exclude_files = "Classes/Exclude"

    s.ios.deployment_target = '12.0'

s.frameworks = 'SwiftyJSON', 'SkeletonView', 'AFNetworking', 'Alamofire', 'EZSwiftExtensions', 'NVActivityIndicatorView', 'ObjectMapper', 'FacebookCore', 'FacebookShare', 'FacebookLogin', 'ADCountryPicker'

end
