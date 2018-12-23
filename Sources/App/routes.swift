import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
    
    let controller = RecordingController()
    router.get("recordings", use: controller.getAll)
//    router.post("recoding-test", use: controller.evaluateData)
    router.post("fetch-gjovik-content", use: controller.startGjovikFetch)
    router.get("lectors", use: controller.listLectors)
    router.get("subjects", use: controller.listSubjects)
}
