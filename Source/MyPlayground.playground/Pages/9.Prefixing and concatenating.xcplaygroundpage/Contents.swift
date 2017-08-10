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
    let middle = PublishSubject<String>()
    
    let source = Observable.of(left.asObserver(), right.asObserver(), middle.asObserver())
    let observable = source.merge(maxConcurrent: 3)
    let disposeable = observable
        .subscribe ({
        print("\($0)")
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    var middleValues = ["Korea", "Japan", "China"]
    
    var i = 0
    repeat {
        i += 1
        let value = arc4random()%3
        switch value {
        case 0:
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        case 1:
            if !rightValues.isEmpty {
                right.onNext("Right: " + rightValues.removeFirst())
            }
        default:
            if !middleValues.isEmpty {
                middle.onNext("Middle: " + middleValues.removeFirst())
            }
        }

    } while (!leftValues.isEmpty || !rightValues.isEmpty || !middleValues.isEmpty) && i < 10
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

// 両方入力されないと反応しない
example(of: "withLatestFrom") {
    
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    let disposable = observable.subscribe(onNext: { (value) in
        print(value)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    //    textField.onNext("Paris")
    
    button.onNext()
    //    button.onNext()
}

// 二つのObservableの中で先onNextした方だけ反応する
example(of: "amb") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: { (value) in
        print(value)
    })
    
    right.onNext("Copenhagen")
    left.onNext("Lisbon")
    left.onNext("Londan")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
}


// 複数のPublishSubjectを受けられるObserver(Observable)タイプで
// 最後受け取ったPublishSubjectに反応する
example(of: "switchLatest") {
    
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { (value) in
        print(value)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("More text from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three, I win")
    
    one.onNext("Nope. It's me, one")
    disposable.dispose()
    
    /*
     --- Example of: switchLatest ---
     Some text from sequence one
     More text from sequence two
     Hey it's three, I win
     */
    
}

// Swiftのreduceと同じ： Arrayの値を合算してくれる
example(of: "reduce") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    // パタン1
    let observable = source.reduce(2, accumulator: { (summary, newValue) -> Int in
        
        print("summary > \(summary)")
        print("newValue > \(newValue)")
        
        return summary + newValue
    })
    
    // パタン2
    //    let observable = source.reduce(0, accumulator: +)
    observable.subscribe(onNext: { value in
        print(value)
    })
}

// 配列のa, b数値を次々に合算、合算するたびにsubscribeに来る
example(of: "scan") {
    
    let source = Observable<Int>.of(1,3,5,7,9)
    let other = Observable<Int>.of(11,12,13,14,15)
    
    let observable = source.scan(0, accumulator: +)
//    let observable = source.scan(other, accumulator: { otherValue, sourceValue in
//        print("other  \(otherValue)") // Observableタイプ
//        print("source \(sourceValue)") //
//        return sourceValue//otherValue
//    })
    
    observable.subscribe(onNext: { (value) in
        print(value)
    })
    
}

// チャレンジ

// zipで加工　→　併合ができる
example(of: "Challenge 1 - solution using zip") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let scanObservable = source.scan(0, accumulator: +)
    
    let observable = Observable.zip(source, scanObservable) { value, runningTotal in
        // value: 元のデータ、runningTotal: 合算結果
        (value, runningTotal)
    }
    observable.subscribe(onNext: { tuple in
        print("Value = \(tuple.0)   Running total = \(tuple.1)")
    })
    
}

// (0,0) (1,1) (3,4) (5,9) (7,16)
example(of: "Challenge 1 - solution using just scan and a tuple") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan((0,0)) { acc, current in
        print(acc.0)
        print(acc.1)
        return (current, acc.1 + current)
    }
    observable.subscribe(onNext: { tuple in
        print("Value = \(tuple.0)   Running total = \(tuple.1)")
    })
    
}



