import Foundation
import RxSwift
import RxCocoa

example(of: "") {
    
    
}


example(of: "amb") {
  let left = PublishSubject<String>()
  let right = PublishSubject<String>()
// 1
  let observable = left.amb(right)
  let disposable = observable.subscribe(onNext: { value in
    print(value)
  })
// 2
  left.onNext("Lisbon")
  right.onNext("Copenhagen")
  left.onNext("London")
  left.onNext("Madrid")
  right.onNext("Vienna")
  disposable.dispose()
}
//ambiguity