//
//  Copyright © 2018 Apparata AB. All rights reserved.
//

import Foundation

public struct BlogConfig {
    
    public struct Templates {
        
        public struct Blog {
            public let template: String
            public let name: String
            public let type: String
        }
        
        public struct Post {
            public let template: String
            public let type: String
        }
        
        public let blog: Blog
        public let post: Post
    }
    
    public let posts: String
    public let templates: Templates
    public let output: String
}

// ---------------------------------------------------------------------------
// MARK: - Codable
// ---------------------------------------------------------------------------

extension BlogConfig: Codable {
    
    enum CodingKeys: String, CodingKey {
        case posts
        case templates
        case output
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        posts = try container.decode(String.self, forKey: .posts)
        templates = try container.decode(Templates.self, forKey: .templates)
        output = try container.decode(String.self, forKey: .output)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(posts, forKey: .posts)
        try container.encode(templates, forKey: .templates)
        try container.encode(output, forKey: .output)
    }
}

extension BlogConfig.Templates: Codable {
    
    enum CodingKeys: String, CodingKey {
        case blog
        case post
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blog = try container.decode(Blog.self, forKey: .blog)
        post = try container.decode(Post.self, forKey: .post)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(blog, forKey: .blog)
        try container.encode(post, forKey: .post)
    }
}

extension BlogConfig.Templates.Blog: Codable {
    
    enum CodingKeys: String, CodingKey {
        case template
        case name
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        template = try container.decode(String.self, forKey: .template)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "index"
        type = try container.decode(String.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(template, forKey: .template)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }
}

extension BlogConfig.Templates.Post: Codable {
    
    enum CodingKeys: String, CodingKey {
        case template
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        template = try container.decode(String.self, forKey: .template)
        type = try container.decode(String.self, forKey: .type)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(template, forKey: .template)
        try container.encode(type, forKey: .type)
    }
}
