//
//  Tests.swift
//  dikitgenTests
//
//  Created by Yosuke Ishikawa on 2017/09/16.
//

import XCTest
import DIGenKit
import DIKit

struct A: Injectable {
    struct Dependency {}
    init(dependency: Dependency) {}
}

struct B: Injectable {
    struct Dependency {
        let ba: A
    }

    init(dependency: Dependency) {}
}

struct C: FactoryMethodInjectable {
    struct Dependency {
        let ca: A
        let cd: D
    }

    static func makeInstance(dependency: C.Dependency) -> C {
        return C()
    }
}

struct D {}

class E: PropertyInjectable {
    struct Dependency {
        let ea: A
        let ec: C
        let eb: B
    }

    var dependency: Dependency!
}

protocol ABCDResolver: DIKit.Resolver {
    func provideD() -> D
}

final class ABCDTests: XCTestCase {
    func test() throws {
        let generator = try CodeGenerator(path: #file)
        let contents = try generator.generate().trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(contents, """
            //
            //  Resolver.swift
            //  Generated by dikitgen.
            //

            import XCTest
            import DIGenKit
            import DIKit

            extension ABCDResolver {

                func resolveA() -> A {
                    return A(dependency: .init())
                }

                func resolveB() -> B {
                    let a = resolveA()
                    return B(dependency: .init(ba: a))
                }

                func resolveD() -> D {
                    return provideD()
                }

                func resolveC() -> C {
                    let a = resolveA()
                    let d = resolveD()
                    return C.makeInstance(dependency: .init(ca: a, cd: d))
                }

                func injectToE(_ e: E) -> Void {
                    let a = resolveA()
                    let c = resolveC()
                    let b = resolveB()
                    e.dependency = E.Dependency(ea: a, ec: c, eb: b)
                }

            }
            """)
    }
}
