
import Foundation
import TemplateKit
import SystemKit

class BlogRenderer {
    
    let config: BlogConfig
    let blogPath: Path
    let outputPath: Path
    let outputPostsPath: Path
    let templatesPath: Path
    
    init(config: BlogConfig, path: Path) {
        self.config = config
        blogPath = path
        outputPath = Path(config.output)
        outputPostsPath = outputPath.appendingComponent("posts")
        templatesPath = blogPath.appendingComponent("templates")
    }
 
    func render(posts: [BlogPost]) throws {
        
        let blogContext = [
            "posts": posts
        ]
        
        let blogTemplatePath = templatesPath.appendingComponent(config.templates.blog.template)
        let blogTemplate = Template(try String(contentsOf: blogTemplatePath.url, encoding: .utf8), tagStart: "{{", tagEnd: "}}")
        
        let renderedBlog = try blogTemplate.render(context: blogContext)
                
        let blogPostsPath = outputPath.appendingComponent(config.templates.blog.name).appendingExtension(config.templates.blog.type)
        
        if outputPostsPath.exists {
            try outputPostsPath.remove()
        }
        
        try outputPath.createDirectory()
                
        try renderedBlog.write(to: blogPostsPath.url, atomically: true, encoding: .utf8)
        
        for post in posts {
            let postContext = [
                "post": post
            ]
            
            let postTemplatePath = templatesPath.appendingComponent(config.templates.post.template)
            let postTemplate = Template(try String(contentsOf: postTemplatePath.url, encoding: .utf8), tagStart: "{{", tagEnd: "}}")
            
            let renderedPost = try postTemplate.render(context: postContext)
                        
            let relativePath = Path(post.relativeURL)
            
            let postDirectory = outputPath + relativePath.deletingLastComponent
            try postDirectory.createDirectory(withIntermediateDirectories: true, attributes: nil)
            
            let postPath = outputPath + relativePath
            try renderedPost.write(to: postPath.url, atomically: true, encoding: .utf8)
            
            for image in post.images {
                let imageFilename = image.lastComponent
                let destinationPath = postDirectory.appendingComponent(imageFilename)
                try image.copy(to: destinationPath)
            }
        }
        
    }
}
