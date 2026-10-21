import UIKit

enum SignatureStore {
    private static var url: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("signature.png")
    }
    static func save(_ image: UIImage) {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? image.pngData()?.write(to: url)
    }
    static func load() -> UIImage? { UIImage(contentsOfFile: url.path) }
}
