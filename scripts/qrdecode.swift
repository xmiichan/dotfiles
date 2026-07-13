import CoreImage
import Foundation

guard CommandLine.arguments.count > 1,
      let img = CIImage(contentsOf:
          URL(fileURLWithPath: CommandLine.arguments[1])) else {
    exit(1)
}
let detector = CIDetector(
    ofType: CIDetectorTypeQRCode,
    context: CIContext(),
    options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
for case let f as CIQRCodeFeature in detector.features(in: img) {
    if let s = f.messageString { print(s) }
}
