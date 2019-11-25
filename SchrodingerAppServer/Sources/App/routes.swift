import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.post("api", "cat") { request -> Future<Cat> in
        return try request.content.decode(Cat.self).flatMap(to: Cat.self) { cat in
            return cat.save(on: request)
        }
    }
    
    router.get("api", "cat") { request -> Future<[Cat]> in
        return Cat.query(on: request).all()
    }
}
