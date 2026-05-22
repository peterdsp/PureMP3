import Foundation

public enum AudioQualityPreset: String, CaseIterable, Identifiable, Sendable {
    case vbrBest
    case vbrBalanced
    case cbr320
    case cbr256
    case cbr192

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .vbrBest:
            "VBR Best"
        case .vbrBalanced:
            "VBR Balanced"
        case .cbr320:
            "320 kbps"
        case .cbr256:
            "256 kbps"
        case .cbr192:
            "192 kbps"
        }
    }

    public var subtitle: String {
        switch self {
        case .vbrBest:
            "Highest quality LAME VBR, usually smaller than 320 kbps CBR."
        case .vbrBalanced:
            "Excellent practical quality with a noticeably smaller file."
        case .cbr320:
            "Maximum fixed MP3 bitrate. Predictable size, not magic compression."
        case .cbr256:
            "Very good music quality with smaller files than 320 kbps."
        case .cbr192:
            "Good general purpose size and quality."
        }
    }

    public var ffmpegArguments: [String] {
        switch self {
        case .vbrBest:
            ["-vn", "-codec:a", "libmp3lame", "-q:a", "0"]
        case .vbrBalanced:
            ["-vn", "-codec:a", "libmp3lame", "-q:a", "2"]
        case .cbr320:
            ["-vn", "-codec:a", "libmp3lame", "-b:a", "320k"]
        case .cbr256:
            ["-vn", "-codec:a", "libmp3lame", "-b:a", "256k"]
        case .cbr192:
            ["-vn", "-codec:a", "libmp3lame", "-b:a", "192k"]
        }
    }

    public var fixedBitrateKilobitsPerSecond: Int? {
        switch self {
        case .vbrBest, .vbrBalanced:
            nil
        case .cbr320:
            320
        case .cbr256:
            256
        case .cbr192:
            192
        }
    }
}
