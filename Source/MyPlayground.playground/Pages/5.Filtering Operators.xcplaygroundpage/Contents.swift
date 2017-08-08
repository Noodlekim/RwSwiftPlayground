//: [Previous](@previous)

import Foundation
import UIKit
import RxSwift
import RxCocoa


example(of: "filter") { 
    
    // 二重フィルター
    Observable<Int>.of(1,2,3,4,5,6,1,7)
        .filter({ $0 != 1 })
        .filter({ $0 % 2 == 0 })
        .subscribe(onNext: { (value) in
            print("value1 >> \(value)")
        })

    // 全てのsubscribeを無視、CompletedとDisposedだけ反応
    // 完了の時のみ処理をしたい時いいらしい
    Observable<Int>.of(1,2,3,4,5,6,1,7)
        .ignoreElements()
    .subscribe(onNext: { (value) in
        print("value2 >> \(value)")
    }, onError: { (error) in
        print("error2 >> \(error)")
    }, onCompleted: { 
        print("onCompleted")
    }, onDisposed: {
        print("onDisposed")
    })
    
}

let imagepreview = UIImageView()
func updatedNavigationIcon() {

    let icon = imagepreview.image?
}
