//: [Previous](@previous)

import Foundation
import RxSwift
import RxCocoa
import UIKit

example(of: "Observable.concat") {
    
    let first = Observable.of(1,2,3)
    let second = Observable.of(4,5,6)
    
    let observable = Observable.concat([first, second])
    observable
        .subscribe ({
            print("\($0)")
        })
    
    first.concat(second)
        .subscribe ({
            print("\($0)")
        })
    
    second.concat(first)
        .subscribe ({
            print("\($0)")
        })

}

example(of: "concat") {
    
    let numbers = Observable.of(2,3,4)
    let observable = Observable
                    .just(1)
                    .concat(numbers)
    
    observable
        .subscribe ({
            print("\($0)")
        })
}

// merge는 그냥 통합해서 받는다는 뜻?
example(of: "merge") { 
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObserver(), right.asObserver())
    let observable = source.merge()
    let disposeable = observable.subscribe ({
        print("\($0)")
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        
        let value = arc4random()%2
        print("\(value)")
        if value == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    disposeable.dispose()
}

// 가장 마지막의 element가 합쳐져서 반영이 됨
// 2개의 신호가 모두 들어와야 동작함
example(of: "combineLatest") { 
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 반환하는 형태는 뭐든지 가능.
    // Conbine이 되면 일반 Observable처럼 filter, map등도 다 걸 수 있음.
//    let observable = Observable.combineLatest(left, right, resultSelector: { lastLeft, lastRight in
//        "\(lastLeft)\(lastRight)"
//    })
//        .map { $0 ?? 0 }
//        .filter { !$0.isEmpty }
    
    let observable = Observable.combineLatest([left, right]) {
        strings in strings.joined(separator: " ") // ??
    }
    
//    Observable.combineLatest([], { (<#[ObservableType.E]#>) -> Element in
//        <#code#>
//    })
    
    let disposable = observable.subscribe ({
        print("\($0)")
    })

    left.onNext("1")
    right.onNext("2")
    right.onNext("3")
    left.onNext("4")

//    left.onNext("Hello,")
//    right.onNext("world")
//    right.onNext("RxSwift")
//    left.onNext("Have a good day,")
    
    /*
     --- Example of: combineLatest ---
    next(Hello, world)
    next(Hello, RxSwift)
    next(Have a good day, RxSwift)
     */
    disposable.dispose()
}

example(of: "") {
    
    
    
}






