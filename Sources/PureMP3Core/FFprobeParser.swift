import Foundation

public enum FFprobeParser {
    public static func parseMediaInfo(from data: Data) throws -> MediaInfo {
        let payload = try JSONDecoder().decode(FFprobePayload.self, from: data)
        let audioStream = payload.streams.first { $0.codecType == "audio" }

        return MediaInfo(
            durationSeconds: payload.format.duration.flatMap(Double.init),
            bitrateBitsPerSecond: payload.format.bitRate.flatMap(Int.init),
            audioCodec: audioStream?.codecName
        )
    }
}

private struct FFprobePayload: Decodable {
    let streams: [Stream]
    let format: Format

    struct Stream: Decodable {
        let codecName: String?
        let codecType: String?

        enum CodingKeys: String, CodingKey {
            case codecName = "codec_name"
            case codecType = "codec_type"
        }
    }

    struct Format: Decodable {
        let duration: String?
        let bitRate: String?

        enum CodingKeys: String, CodingKey {
            case duration
            case bitRate = "bit_rate"
        }
    }
}
