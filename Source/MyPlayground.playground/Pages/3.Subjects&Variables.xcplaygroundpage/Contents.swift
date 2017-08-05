//: [Previous](@previous)

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case anError
}

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    
    let subscriptionOne = subject
        .subscribe(onNext: { (news) in
            print("1) \(news)")
        })
    
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
    }

    subject.onNext("news desuyo")
//    subscriptionOne.dispose()

    subject.on(.next("1"))

    subject.onNext("3")
    
    // 1
//    subject.onCompleted()
    // 2
    subject.onNext("5")
    // 3
//    subscriptionTwo.dispose()
    // DisposeBag를 해도 마찬가지 결과
    let disposeBag = DisposeBag()
    // 4
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("?")
}

example(of: "BehaviorSubject") {

    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    let subscriptionOne = subject
    subscriptionOne
        .subscribe(onNext: { (element) in
            print("1) > \(element)")
        }, onError: { (error) in
            print("1) > \(error)")
        })
        .disposed(by: disposeBag) // 이렇게 해두면 Object가 해제될 때 구독도 다 같이 해제가 되니 좋다? 일일이 dispose를 안걸어도 좋을 듯.
    
    subscriptionOne.dispose()
    
    let subscriptionTwo = subject
    subscriptionTwo
        .subscribe(onNext: { (element) in
            print("2) > \(element)")
        }, onError: { (error) in
            print("2) > \(error)")
        })
    subject.onNext("next event")
//    subscriptionOne
//        .subscribe({ (event) in
//            print("1) \(event)")
//        })
    subject.onError(MyError.anError)
}


// 검색키워드 처럼 최근 onNext된 정보를 다음번에 subscribe를 하는 구독자가 볼 수 있도록 함.
// Good! 다만 메모리상의 캐싱이지 영속적인 캐싱은 아니기 때문에 처음에는 plist나 데이터베이스에서 로드를 해야함.
example(of: "ReplaySubject") {
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")

    subject
        .subscribe {
            print("1) event\($0)")
        }
        .disposed(by: disposeBag)
    
//    subject.dispose()
    subject
        .subscribe {
            print("2) event\($0)")
        }
        .disposed(by: disposeBag)
    subject.onNext("4")
    subject.onError(MyError.anError)
}

example(of: "Variable") {

    var variable = Variable<String>.init("init value")
    let disposeBag = DisposeBag()

    variable.asObservable()
        .subscribe(onNext: { (value) in
            print("1) value \(value)")
        })
        .disposed(by: disposeBag)
    
    variable.value = "second value"
    
    // 2
    variable.asObservable()
        .subscribe(onNext: { (value) in
            print("2) value \(value)")
        })
        .disposed(by: disposeBag)
    // 3
    variable.value = "2"
    
    // Publish랑 Observable랑 달라서 이런거 못씀. 무조껀 반영을 하는 걸로?
//    variable.value.onError(MyError.anError)
//    variable.asObservable().onError(MyError.anError)
//    variable.value = MyError.anError
//    variable.value.onCompleted()
//    variable.asObservable().onCompleted()
}