import Foundation

public protocol LoopClock: Sendable {
    func now() -> Date
}
