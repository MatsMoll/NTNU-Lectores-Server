import XCTest
@testable import App

class AppTests: XCTestCase {
    
    enum Errors: Error {
        case noNodesFound
    }
    
    
    func testStub() throws {
        XCTAssert(true)
    }
    
    func testNodeRecordCreation() {
        let duration = 105
        let lector = "Jo Sterten"
        let title = "3 DTEC TA"
        let subject = "TEK3106"
        let info = "Muntlig fremføring"
        let audioPath = "1544710861-ed4d757943ac/audio.mp3"
        let cameraPath = "1544710861-ed4d757943ac/camera.mp4"
        let screenPath = "1544710861-ed4d757943ac/screen.mp4"
        let combinedPath = "1544710861-ed4d757943ac/combined.mp4"
        
        let baseUrl = "https://forelesning.gjovik.ntnu.no/"
        
        let file = """
<tr class="lecture">
  <td>2018-12-13 13:35</td>
  <td>\(duration) min</td>
  <td>\(lector)</td>
  <td>\(title)</td>
  <td class="topic">\(subject)</td>
  <td>
        <a href="\(audioPath)" title="Audio, MP3">Audio</a>
        <a href="\(cameraPath)" title="Camera - MP4">Camera</a>
        <a href="\(screenPath)" title="Screen - MP4">Screen</a>
        <a href="\(combinedPath)" title="Combined camera and screen - MP4">Combined</a>
  </td>
  <td style="text-align:center;">
        <img alt="Muntlig fremføring" title="\(info)" src="/images/information.png">
  </td>
</tr>
"""
        do {
            let document = try XMLDocument(xmlString: file, options: .documentTidyHTML)
            guard let node = try document.nodes(forXPath: "//tr").first else {
                throw Errors.noNodesFound
            }
            let recording = try Recording.create(from: node, baseUrl: baseUrl)
            
            XCTAssert(recording.duration == duration, "Duration is incorrect")
            XCTAssert(recording.lector == lector, "Lector is incorrect")
            XCTAssert(recording.title == title, "Tilte is incorrect")
            XCTAssert(recording.subject == subject, "Subject is incorrect")
            XCTAssert(recording.info == info, "Info is incorrect")
            
            XCTAssert(recording.audioUrl == baseUrl + audioPath, "audioPath is incorrect")
            XCTAssert(recording.cameraUrl == baseUrl + cameraPath, "cameraPath is incorrect")
            XCTAssert(recording.screenUrl == baseUrl + screenPath, "screenPath is incorrect")
            XCTAssert(recording.combinedMediaUrl == baseUrl + combinedPath, "combinedPath is incorrect")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    static let allTests = [
        ("testStub", testStub),
    ]
}
