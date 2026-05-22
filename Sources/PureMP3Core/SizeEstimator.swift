import Foundation

public enum SizeEstimator {
    public static func estimatedBytes(durationSeconds: Double, bitrateKilobitsPerSecond: Int) -> Int64 {
        let bits = durationSeconds * Double(bitrateKilobitsPerSecond) * 1_000
        return Int64(bits / 8)
    }

    public static func humanReadable(bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.includesCount = true
        return formatter.string(fromByteCount: bytes)
    }
}
