import Trio

@main
struct OrefSpike {
    static func main() throws {
        print (try OrefSpikeBridge.runFixture())
    }
}
