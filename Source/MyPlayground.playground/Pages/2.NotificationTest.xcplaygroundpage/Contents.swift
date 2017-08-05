//: [Previous](@previous)

import Foundation
import UIKit
import RxSwift
import RxCocoa

example(of: "Observable") {

    let disposeBag = DisposeBag()
    
    // 一般的なNotification処理
    NotificationCenter.default.addObserver(forName: NSNotification.Name.init("Notification"), object: nil, queue: nil, using: { (notification) in
        // Handle receiving notification
    })
    
    NotificationCenter.default.rx.notification(Notification.Name.init("test"))
        .subscribe(onNext: { (notification) in
            print("get notification!! \(notification)")
        })
        .disposed(by: disposeBag)

    
    // Notification for test
    // NotificationCenter.default.post(name: NSNotification.Name.init("test"), object: nil)
    

    let observe: Observable<String> = Observable.create({ (observer) -> Disposable in
        observer.onNext("test2")
        return Disposables.create()
    })
    
    observe
        .subscribe({ (event) in
            print("event \(event)")
            print("element > \(event.element)")

            if let error = event.error {
                print("error \(event.error)")
            }
            
        })
}
