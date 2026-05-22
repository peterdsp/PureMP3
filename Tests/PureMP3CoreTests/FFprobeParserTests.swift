import Foundation
import Testing
@testable import PureMP3Core

@Suite
struct FFprobeParserTests {
    @Test
    func parsesMediaInfo() throws {
        let json = """
        {
          "streams": [
            {
              "codec_name": "mp3",
              "codec_type": "audio"
            }
          ],
          "format": {
            "duration": "184.200000",
            "bit_rate": "320000"
          }
        }
        """

        let info = try FFprobeParser.parseMediaInfo(from: Data(json.utf8))

        #expect(info.durationSeconds == 184.2)
        #expect(info.bitrateBitsPerSecond == 320000)
        #expect(info.audioCodec == "mp3")
        #expect(info.isLossyMP3)
    }
}
