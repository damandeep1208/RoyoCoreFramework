Pod::Spec.new do |s|  
    s.name              = 'RoyoCoreFramework'
    s.version           = '0.0.1'
    s.summary           = 'The core framework includes Location manager, login with apple, Table view and collection view datasource classes, unary prefix for unwrapping option manager, Facebook login manager'
    s.homepage          = 'https://royoapps.com'

    s.author            = { 'Name' => 'damandeep@codebrewinnovations.com' }
    s.license           = { :type => 'MIT', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :git => "https://bitbucket.org/damancb/royocoreframework.git", :tag => "0.0.1" }

    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'RoyoCoreFramework.framework'

s.frameworks = 'SwiftyJSON', 'SkeletonView', 'AFNetworking', 'Alamofire', 'EZSwiftExtensions', 'NVActivityIndicatorView', 'ObjectMapper', 'FacebookCore', 'FacebookShare', 'FacebookLogin', 'ADCountryPicker'

end
