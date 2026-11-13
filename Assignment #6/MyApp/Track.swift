import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String

    var resourceName: String {
        let name = (fileName as NSString).deletingPathExtension
        return name.isEmpty ? fileName : name
    }

    var fileExtension: String {
        let ext = (fileName as NSString).pathExtension
        return ext.isEmpty ? "m4a" : ext
    }
}
