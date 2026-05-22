import Foundation

public struct ConversionJob: Identifiable, Equatable, Sendable {
    public enum State: Equatable, Sendable {
        case ready
        case running(progress: Double?)
        case completed(outputURL: URL)
        case failed(message: String)
        case cancelled
    }

    public let id: UUID
    public let inputURL: URL
    public var outputURL: URL
    public var state: State
    public var mediaInfo: MediaInfo?

    public init(
        id: UUID = UUID(),
        inputURL: URL,
        outputURL: URL,
        state: State = .ready,
        mediaInfo: MediaInfo? = nil
    ) {
        self.id = id
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.state = state
        self.mediaInfo = mediaInfo
    }
}

public struct MediaInfo: Equatable, Sendable {
    public let durationSeconds: Double?
    public let bitrateBitsPerSecond: Int?
    public let audioCodec: String?

    public init(durationSeconds: Double?, bitrateBitsPerSecond: Int?, audioCodec: String?) {
        self.durationSeconds = durationSeconds
        self.bitrateBitsPerSecond = bitrateBitsPerSecond
        self.audioCodec = audioCodec
    }

    public var isLossyMP3: Bool {
        audioCodec?.lowercased() == "mp3"
    }
}
