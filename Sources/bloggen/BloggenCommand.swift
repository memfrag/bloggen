import Foundation
import ArgumentParser
import SystemKit
import bloggenKit

enum AppError: LocalizedError {

    case noConfigFile

    var errorDescription: String? {
        switch self {
        case .noConfigFile:
            return "Error: Unable to find blogfile.json config file in current directory."
        }
    }
}

extension Path: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}

@main
struct BloggenCommand: ParsableCommand {

    @Flag(name: .shortAndLong, help: "Verbose output")
    var verbose: Bool = false

    @Argument(help: "Path to blogfile.json blog config file.")
    var path: Path

    func run() throws {
        let configFilePath = path.isDirectory
            ? path.appendingComponent("blogfile.json")
            : path

        guard configFilePath.exists else {
            throw AppError.noConfigFile
        }

        let config = try Data(contentsOf: configFilePath.url)

        let blogDirectory = configFilePath.deletingLastComponent

        try bloggenKit.buildBlog(at: blogDirectory, config: config, verbose: verbose)
    }
}
