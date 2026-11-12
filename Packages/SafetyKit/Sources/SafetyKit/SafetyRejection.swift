public enum SafetyRejection: Error, Sendable, Equatable {
    case bolusLimitExceeded
    case iobLimitExceeded
    case invalidContext
    case pumpUnavailable
    case deliveryPending
    case confirmationRequired
    case invalidRequestTime
}
