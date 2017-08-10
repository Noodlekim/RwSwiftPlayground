//: [Previous](@previous)

import Foundation
import RxSwift
import RxCocoa


// Error Handling!!

enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

public enum NohanaError: Error {
    case invalidData
    case common(code: String, discription: String)
    case outOfTime
}



//extension OyaError {
//    
//    case failSingUp
//    case failLogin
//}

//func canThrowErrors() throws -> String


class ClassA {
    
    func checkError(error: NohanaError) {
        
        switch error {
        case .invalidData:
            print("invalidData")
        case .common(let code, let discription):
            print("invalidData \(code) == \(discription)")
        case .outOfTime:
            print("outOfTime")

        }
    }
}
ClassA.init().checkError(error: .common(code: "201", discription: "エラーですね"))



/// リトライ
var count = 0
let observer = Observable<Int>.create({ (observer) -> Disposable in
    
//    throw NohanaError.invalidData

    if count < 2 {
        print("エラーを返す \(count)")
        observer.onError(NohanaError.invalidData)
    } else {
        print("エラーなし")
        observer.onNext(100)
    }
    
    count += 1
    return Disposables.create()
})
    
observer
    .delay(1.0, scheduler: MainScheduler.instance)
    .retry(3)
    .subscribe(onNext: { event in
        print("Receive event: \(event)")
    })



var testCount = 0

func fetch() -> Observable<String> {
    
    let request: Observable<String> = Observable<String>.create { (observer) -> Disposable in

        // リクエスト設定
        observer.onNext("Create request!")
        return Disposables.create()
    }
    
    return request.flatMap({ value in
        
        return Observable<String>.of("Response!").map({ (value) -> String in
            
            if testCount < 3 {
                testCount += 1
                print("retry \(testCount)")
                throw NohanaError.invalidData
            }
            
            return "Success" + value
        })
    })
}

fetch()
    .retry(3)
    .subscribe(onNext: { (value) in
        print("subscribe >> \(value)")
    }, onError: { (error) in
        print("error > \(error)")
    }, onCompleted: {
        print("onCompleted")
    }) { 
        print("onDisposed")
    }








