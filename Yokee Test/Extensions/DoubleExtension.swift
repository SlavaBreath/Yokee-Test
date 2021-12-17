import Foundation

extension Double {
    var percentString: String {
        formatted(.percent.precision(.fractionLength(0...1)))
    }
}
