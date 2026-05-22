import Testing
@testable import PureMP3Core

@Suite
struct SizeEstimatorTests {
    @Test
    func estimatesConstantBitrateMP3Size() {
        let bytes = SizeEstimator.estimatedBytes(
            durationSeconds: 60,
            bitrateKilobitsPerSecond: 320
        )

        #expect(bytes == 2_400_000)
    }
}
