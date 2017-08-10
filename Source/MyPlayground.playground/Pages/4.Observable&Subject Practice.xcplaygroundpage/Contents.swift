

import Foundation
import UIKit
import RxSwift
import RxCocoa

example(of: "take") { 
    
    let disposeBag = DisposeBag()
    
    Observable.of(1,2,3,1,2,3)
        .skip(1)
//        .skipWhile({ $0 < 2 }) // ture -> skip, false -> no skip 한번 스킵이 해제가 되면 그다음부터 안봄
//        .take(1) // 필터에 의해서 한번 조건만큼 onNext를 받고 그이후로는 다 차단
        .throttle(1.0, scheduler: MainScheduler.instance) // 0.3초 동안 막아줌.
        .take(10, scheduler: MainScheduler.instance)
        .subscribe(onNext: { (value) in
            print("value > \(value)")
        }, onDisposed: {
            print("onDisposed")
        })
//        .subscribe()

        .disposed(by: disposeBag)
}

example(of: "takeWhileWithIndex") { 
    let disposeBag = DisposeBag()
    
    // Whileなのでいったん止まったらできない
    Observable.of(1,2,3,4,5,6)
        .takeWhile({ (value) -> Bool in
            return value < 3
        })
        //    .take(2)
        .subscribe(onNext: { (value) in
            print("value > \(value)")
        })
        .disposed(by: disposeBag)
}

/// trigger Subjectが動くまでのsubscribeをする
example(of: "takeUltil") { 
    
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    subject
        .takeUntil(trigger)
        .subscribe(onNext: { (value) in
            print("\(value)")
        })
        .disposed(by: disposeBag)
    
    trigger
    .subscribe(onNext: { (value) in
        print("\(value)")
    })
    
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("3")
    subject.onNext("4")
    trigger.onNext("5")
    
}

/// 同じ値が連続でsubscribeされることを防止
example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: { (value) in
            print("\(value)")
        })
}


// 条件で重複を判断
// ture => 反映しない、 false => 反映する
example(of: "distinctUntilChanged(_:)") {
    
    let disposeBag = DisposeBag()
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged({ (a, b) -> Bool in
//            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
//            let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
//                return false
//            }
//            print("\(a)")
//            print("\(b)")
//            print("\(aWords)")
//            print("\(bWords)")
//            
//            var containsMatch = false
//            
//            for aWord in aWords {
//                for bWord in bWords {
//                    if aWord == bWord {
//                        containsMatch = true
//                        break
//                    }
//                }
//            }
//            print("=====> \(containsMatch)")
//            return containsMatch
            return false
        })
    .subscribe(onNext: { (value) in
        print("next \(value)")
    })
    .disposed(by: disposeBag)
    
}

// 条件: 最初0は電話番号として使えない
example(of: "CreatePhoneNumbers") {

    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined() // ふぉ
        print("inputed numbers >> \(phone)")
        phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 3))
        phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 7))
        
        return phone
    }

    
    let disposeBag = DisposeBag()
    
    var contracts = [String]()
    var numbers = [Int]()
    let inputSubject = PublishSubject<Int>()
    inputSubject
        .filter({ $0 >= 0 })
        .subscribe(onNext: { (value) in
            if numbers.count == 0 && "\(value)".characters.first! == "0" {
                print("invalidate value >> \(value)")
                return
            }
            print("subscribe >> \(value)")
            
            "\(value)".characters.forEach({
                if let number = (Int("\($0)")) {
                    numbers.append(number)
                    if numbers.count >= 10 {
                        let newNumber = phoneNumber(from: numbers)
                        contracts.append(newNumber)
                        
                        print("\(contracts)")
                        numbers = []
                    }
   
                }
            })
        })
        .disposed(by: disposeBag)
    
    inputSubject.onNext(0)
    inputSubject.onNext(630)
    inputSubject.onNext(2)
    inputSubject.onNext(1)
    inputSubject.onNext(1)
    inputSubject.onNext(1)
    inputSubject.onNext(1)
    inputSubject.onNext(630)

    inputSubject.onNext(630)
    inputSubject.onNext(630)
    inputSubject.onNext(630)
    inputSubject.onNext(630)
    inputSubject.onNext(630)
    inputSubject.onNext(630)
    inputSubject.onNext(630)
}
