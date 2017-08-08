

import Foundation
import UIKit
import RxSwift
import RxCocoa



example(of: "toArray") {
    
    
    let disposeBag = DisposeBag()
    Observable<String>.of("1", "2", "3", "4", "5")
        .toArray()
        .subscribe(onNext: { (value) in
            print("\(value)")
        })
}

example(of: "map") { 
    
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter.init()
    formatter.numberStyle = .spellOut
    Observable<NSNumber>.of(123, 4, 567)
        .map {
            formatter.string(from: $0) ?? ""
        }
        .subscribe ({
            print($0)
        })
        .disposed(by: disposeBag)
    /*
     next(Optional("one hundred twenty-three"))
     next(Optional("four"))
     next(Optional("five hundred sixty-seven"))
     */
}

example(of: "mapWithIndex") { 
    
    
    let disposeBag = DisposeBag()

    Observable.of(1,2,3,4,5,6)
        .mapWithIndex({ value, index in
            index > 2 ? value * 2 : value
        })
        .subscribe ({
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
        --- Example of: mapWithIndex ---
        next(1)
        next(2)
        next(3)
        next(8)
        next(10)
        next(12)
        completed
     */
}



