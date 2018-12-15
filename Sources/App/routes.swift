import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
    
    let controller = RecordingController()
    router.get("recordings", use: controller.getAll)
}
