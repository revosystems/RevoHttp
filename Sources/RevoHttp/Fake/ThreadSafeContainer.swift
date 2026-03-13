protocol Resolvable{
    init()
}

actor ThreadSafeContainer {
    
    nonisolated static let shared = ThreadSafeContainer()
    
    private var resolvers: [String: Any] = [:]
    
    func bind<T, Z>(instance type: T.Type, _ resolver: Z) {
        resolvers[String(describing: type)] = resolver
    }
    
    func unbind<T>(_ type: T.Type) {
        resolvers.removeValue(forKey: String(describing: type))
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        resolve(withoutExtension: type)
    }
    
    func resolve<T>(withoutExtension type: T.Type) -> T? {
        guard let resolver = resolvers[String(describing: type)] else {
            if type.self is Resolvable.Type {
                return (type as! Resolvable.Type).init() as? T
            }
            return nil
        }
        if let resolvable = resolver as? Resolvable.Type {
            return resolvable.init() as? T
        }
        if let resolvable = resolver as? T {
            return resolvable
        }
        if let resolvable = resolver as? (()->T) {
            return resolvable()
        }
        return nil
    }
}
