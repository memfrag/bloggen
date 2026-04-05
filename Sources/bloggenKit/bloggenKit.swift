import Foundation
import SystemKit

public func buildBlog(at blogPath: Path, config configData: Data, verbose: Bool) throws {
    
    let config = try parseConfigData(configData)
    
    let blog = Blog(config: config, path: blogPath)
    try blog.generatePosts()
}

public func parseConfigData(_ data: Data) throws -> BlogConfig {
    return try JSONDecoder().decode(BlogConfig.self, from: data)
}
