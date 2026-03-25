import SwiftUI

extension Animation {
    static let dnTabSwitch = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let dnCardEntry = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let dnButtonPress = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let dnActiveScale = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let dnModalPresent = Animation.spring(response: 0.4, dampingFraction: 0.85)
}
