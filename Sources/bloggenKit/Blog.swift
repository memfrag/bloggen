
import Foundation
import SystemKit
import TextToolbox
import CollectionKit
import Markin

class Blog {
    
    private let config: BlogConfig
    private let path: Path
    private let blogRenderer: BlogRenderer
    
    private let stringToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    init(config: BlogConfig, path: Path) {
        self.config = config
        self.path = path
        blogRenderer = BlogRenderer(config: config, path: path)
    }
    
    func generatePosts() throws {
        
        let postsPath = path.appendingComponent(config.posts)
        guard postsPath.exists, postsPath.isDirectory else {
            throw BlogError.cannotFindPostsDirectory
        }
        
        let dateRegex = Regex("^20\\d\\d-\\d\\d-\\d\\d$")
        
        let dayPaths = try postsPath.contentsOfDirectory().filter {
            dateRegex.isMatch($0.lastComponent)
        }
        
        let posts = try loadPosts(at: postsPath, dayPaths: dayPaths)
        
        try blogRenderer.render(posts: posts)
    }
    
    private func loadPosts(at postsPath: Path, dayPaths: [Path]) throws -> [BlogPost] {
        
        var posts: [BlogPost] = []
        for dayPath in dayPaths {
            let day = dayPath.lastComponent
            let dayPosts = try loadPostsForDay(at: postsPath, day: day, dayPath: dayPath)
            posts.append(contentsOf: dayPosts)
        }
        
        return posts.sorted().reversed()
    }
    
    private func loadPostsForDay(at postsPath: Path, day: String, dayPath: Path) throws -> [BlogPost] {
        
        guard let date = stringToDateFormatter.date(from: day) else {
            throw BlogError.invalidDateFormat
        }
        
        let markdownFiles = try (postsPath + dayPath).contentsOfDirectory()
            .filter { $0.extension == "md" }
        
        var posts: [BlogPost] = []
        
        for markdownFile in markdownFiles {
            let markdownPath = postsPath + dayPath + markdownFile
            let markdown = try String(contentsOf: markdownPath.url, encoding: .utf8)
            let blogPost = try makeBlogPost(from: markdown, date: date, imagesPath: postsPath + dayPath)
            posts.append(blogPost)
        }
        
        return posts
    }
    
    private func makeBlogPost(from markdown: String, date: Date, imagesPath: Path) throws -> BlogPost {
        
        print(markdown)
        
        let parser = MarkinParser()
        let document = try parser.parse(markdown)
        
        let toc = makeTableOfContents(from: document)
        
        let titleNode = document.blocks.first {
            ($0 as? HeaderElement)?.level == 1
        } as? HeaderElement
        
        _ = document.blocks.removeFirst {
            ($0 as? HeaderElement)?.level == 1
        }
        
        let preambleNode = document.blocks.first {
            $0 is ParagraphElement
        } as? ParagraphElement
        
        _ = document.blocks.removeFirst {
            $0 is ParagraphElement
        }
                
        let html = document.formatAsHTML()
        
        let title = titleNode?.content.formatAsText() ?? "(Untitled)"
        
        let preamble = preambleNode?.formatAsText() ?? ""
        
        let images = gatherImages(in: document)
            .filter {
                $0.scheme == nil
            }
            .map {
                imagesPath + Path($0.path)
            }
        
        let post = BlogPost(date: date, title: title, preamble: preamble, toc: toc, html: html, images: images)
        
        return post
    }
    
    private func gatherImages(in document: DocumentElement) -> [URL] {
        return gatherImages(in: document.blocks)
    }
    
    private func gatherImages(in blocks: [BlockElement]) -> [URL] {
        return blocks.flatMap { gatherImages(in: $0) }
    }
    
    private func gatherImages(in block: BlockElement) -> [URL] {
        if let block = block as? BlockQuoteElement {
            return gatherImages(in: block.content)
        } else if let block = block as? HeaderElement {
            return gatherImages(in: block.content)
        } else if let block = block as? ParagraphElement {
            return gatherImages(in: block.content)
        } else if let block = block as? ListElement {
            return gatherImages(in: block.entries)
        } else {
            return []
        }
    }
    
    private func gatherImages(in paragraphs: [ParagraphElement]) -> [URL] {
        return paragraphs.flatMap { gatherImages(in: $0) }
    }
    
    private func gatherImages(in paragraph: ParagraphElement) -> [URL] {
        return gatherImages(in: paragraph.content)
    }

    private func gatherImages(in elements: [InlineElement]) -> [URL] {
        return elements.flatMap { gatherImages(in: $0) }
    }

    private func gatherImages(in element: InlineElement) -> [URL] {
        if let element = element as? BoldElement {
            return gatherImages(in: element.content)
        } else if let element = element as? ItalicElement {
            return gatherImages(in: element.content)
        } else if let element = element as? ImageElement {
            return [URL(string: element.url)].compactMap { $0 }
        } else {
            return []
        }
    }

    private func makeTableOfContents(from document: DocumentElement) -> String {
        var sections: [String] = []
        for (index, block) in document.blocks.filter({ $0 is HeaderElement }).enumerated() {
            if let header = block as? HeaderElement {
                let text = header.content.formatAsText()
                let anchor = header.formatAsAnchorID()
                if index == 0 {
                    sections.append("<div id=\"toc-header-\(index + 1)\" class=\"active\"><a href=\"#top\">\(text)</a></div>")
                } else {
                    sections.append("<div id=\"toc-header-\(index + 1)\"><a href=\"#\(anchor)\">\(text)</a></div>")
                }
            }
        }
        
        return sections.joined(separator: "\n                    ")
    }
}
