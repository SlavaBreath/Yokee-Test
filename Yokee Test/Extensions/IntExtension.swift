import Foundation

extension Int {
    var mbString: String {
        let oneMB: Float = 1_024 * 1_024
        let inMB = Float(self) / oneMB
        return "\(inMB.formatted(.number.precision(.fractionLength(0...1))))MB"
    }
}
