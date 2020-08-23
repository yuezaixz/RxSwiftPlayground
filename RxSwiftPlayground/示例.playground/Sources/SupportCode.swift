import Dispatch

public func example(_ description: String, action: () -> Void) {
    printExampleHeader(description)
    action()
}

public func printExampleHeader(_ description: String) {
    print("\n--- \(description) example ---")
}

public enum TestError: Swift.Error {
    case test
}

public func delay(_ delay: Double, closure: @escaping () -> Void) {

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

#if NOT_IN_PLAYGROUND
    
    public func playgroundShouldContinueIndefinitely() { }
    
#else
    
    import PlaygroundSupport
    
    public func playgroundShouldContinueIndefinitely() {
        PlaygroundPage.current.needsIndefiniteExecution = true
    }
    
#endif

