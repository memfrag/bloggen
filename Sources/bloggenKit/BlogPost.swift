
import Foundation
import SystemKit

public class BlogPost {
    
    let date: Date
    let dateText: String

    let title: String
    
    let preamble: String
    
    let relativeURL: String
    
    let toc: String
    
    let html: String
    
    let images: [Path]
    
    init(date: Date, title: String, preamble: String, toc: String, html: String, images: [Path]) {
        self.date = date
        self.title = title
        self.preamble = preamble
        self.toc = toc
        self.html = html
        self.images = images
        dateText = dateFormatter.string(from: date)
        relativeURL = "posts/\(fileDateFormatter.string(from: date))/\(fileSafe(string: title)).html"
    }
    
}

extension BlogPost: Comparable {
    public static func == (lhs: BlogPost, rhs: BlogPost) -> Bool {
        return lhs.date == rhs.date && lhs.title == rhs.title
    }
    
    public static func < (lhs: BlogPost, rhs: BlogPost) -> Bool {
        if lhs.date == rhs.date {
            return lhs.title < rhs.title
        } else {
            return lhs.date < rhs.date
        }
    }
    
    
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

private let fileDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private func fileSafe(string: String) -> String {
    let chars: [Character] = string
        .trimmed()
        .lowercased()
        .map { char in
            if "abcdefghijklmnopqrstuvwxyz0123456789".contains(char) {
                return char
            } else {
                return Character("-")
            }
    }
    return String(chars)
}
