//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa

//func example(of param: String, () -> Void) {
//    print("success \(param)")
//}
//
//example(of: "just, of, from") { 
//    
//    let one = 1
//    let two = 2
//    let three = 3
//    
//    let observable: Observable<Int> = Observable<Int>.just(one)
//}

example(of: "Observable") { 
    
    var one: Int = 1
    var two = 4
    var three = 6
    
    let observable = Observable<Int>.just(one)
    
    
    //.subscribe(onNext: { (value) in
    //    print("onNext value is \(value)")
    //}, onError: { (error) in
    //    print("error is \(error)")
    //}, onCompleted: {
    //    print("completed")
    //}) {
    //    print("onDiposed")
    //}
    
    let observable2 = Observable.of(one, two, three)
    let observable3 = Observable.of([one, two, three])
    // from으로 하면 배열 안에 것도 빼낼 수가 있다.
    let observable4 = Observable.from([one, two, three])
    observable
        .subscribe(onNext: { (newValue) in
            print("changed newValue \(newValue)")
        })
    
    
    observable2.subscribe(onNext: { (element) in
        print("newValue \(element)")
    })
    
    observable3.subscribe(onNext: { (element) in
        print("newValue \(element)")
    })
    
    observable4.subscribe(onNext: { (element) in
        print("newValue \(element)")
    })
}


example(of: "empty") { 
    
    let observable = Observable<Any>.empty()
    observable
        .subscribe(onNext: { (element) in
            print(element)
        }, onCompleted: { 
            print("Completed")
        })
}

example(of: "never") {
    
    let observable = Observable<Any>.never()
    observable
        .subscribe(onNext: { (element) in
            print(element)
        }, onCompleted: {
            print("Completed")
        })
}

example(of: "range") {
    
    let observable = Observable<Int>.range(start: 1, count: 10)
    observable
        .subscribe(onNext: { (i) in
            let n = Double(i) + 1000
            print(n)
        }, onCompleted: {
            print("Completed")
        })
}


example(of: "dispose") {

    let observable = Observable.of(["A", "B", "C"])
    // 이 행위 자체가 해당 Observe를 바로 subScribe하겠다는 뜻
    let subscription = observable
                    .subscribe({ (event) in
                            print(event)
                        })
    
    observable
        .subscribe(onNext: { (strings) in
            print("strings> \(strings)")
        }, onCompleted: { 
            print("completed")
        }, onDisposed: { 
            print("Disposed")
        })
}


// 예를 들어서 VM에서 데이터를 받음 -> 결과를 처리 -> Result<data, Error>형태로 만듬 -> 이걸 VC에 던져주기 위한 작업?
// fetch의 결과를 Observable<Result<Data, NHError>> 형태로 만들고 그걸 return
// create { } 안에서 결과를 처리를 하고 Result나 Error를 반환을 함.
example(of: "test") {
    
    let observable = Variable<Array<String>>.init(["A", "B", "C"])//Observable.of(["A", "B", "C"])
    
    var testOb: Any?
//    let ob = Observable<Any>.create({ (observer) -> Disposable in
//        
//      observer.onNext("asdf")
//        return Disposables.create()
//    })
    
    observable.asObservable()
        .subscribe({ (event) in
            print("event1 > \(event)")
        })

    observable.value = ["1", "2", "3"]
    observable.asObservable()
        .subscribe({ (event) in
        print("event2 > \(event)")
    })
    
}


example(of: "disposeBag") {
    
    let disposeBag = DisposeBag()
    Observable.of(["A", "B", "C"])
        .subscribe({
            print("?? -> \($0)")
        })
        .disposed(by: disposeBag)
    
}

// 이 Observable를 어떻게 처리를 하느냐가 중요할 듯.
// Dispose가 마음대로 되는게 이해가 안됨. disposed가 되는 행위 자체가 일단 메모리상에서 뺀다는 건가?
// Completed랑 Dispose의 개념을 이해하는게
// > 그럼 처음부터 Observable를 가지지 말고... Observable의 형태를 원하는 타이밍에 onNext, onCompleted를 할 수 있어야 하는거 아닌가?
example(of: "create") {
    
    let disposeBag = DisposeBag()
    Observable<String>.create({ (observer) -> Disposable in
        observer.onNext("start")
//        observer.onCompleted()
        observer.onNext("end")
        observer.onNext("end2")
        observer.onCompleted()
        
        return Disposables.create()
    })
    .subscribe(onNext: { (value) in
        print("value >\(value)")
    }, onError: { (error) in
        print("error >\(error)")
    }, onCompleted: { 
        print("completed")
    }, onDisposed: { 
        print("disposed")
    })
    .disposed(by: disposeBag)
    
    

}

// ただのCompletedだけを監視するためのObservable?
example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable
        .subscribe(
            // 1
            onNext: { element in
                print("element > \(element)")
        },
            // 2
            onCompleted: {
                print("Completed")
        } )
}

// 何も購読できないのに監視する意味があるかな？
// →　Disposedの時は反応する？　これはどういう意図？
example(of: "never") {
    //    let observable = Observable<Any>.never()
    //    observable
    //        .subscribe(
    //            onNext: { element in
    //                print("element > \(element)")
    //        },
    //            onCompleted: {
    //                print("Completed2")
    //        }
    //    )
    
    let observable = Observable<Any>.never()
    
    let disposeBag = DisposeBag()
    
    observable
        //        .debug()
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed")
        },
            onDisposed: {
                print("Disposed")
        })
        .disposed(by: disposeBag)
    
}

// 말그대로 대기 상s태로 두고 조건에 따른 Observable를 만들어서 보내는 형식으로 하고 싶을 때 사용 하는 듯.
example(of: "deferred") {
    let disposeBag = DisposeBag()
    // 1
    var flip = false
    // 2
    let factory: Observable<Int> = Observable.deferred {
        // 3
        flip = !flip
        // 4
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
            .disposed(by: disposeBag)
        print()
    }
}

// 각각의 변수를 감시하는 옵저버인가?
//one = 4


/*
NotificationCenter.default.rx.notification(Notification.Name.UIDeviceOrientationDidChange)
    .filter { (notification) -> Bool in
        guard let orientation = notification.object as? UIDeviceOrientation else {
            return false
        }
        switch orientation {
        case .portrait:
            print("portrait")
            return false
        default:
            print("other")
            return false
        }
    }
    .map { (notification) in
        return "good!"
    }
    .subscribe { (value) in
        print(value)
    }
*/
//NSNotificationCenter.defaultCenter().rx_notification(UIDeviceOrientationDidChangeNotification)



