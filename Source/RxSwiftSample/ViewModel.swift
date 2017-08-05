//
//  ViewModel.swift
//  RxSwiftSample
//
//  Created by キム ギボン on 2017/08/03.
//  Copyright © 2017年 キム ギボン. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    
    deinit {
        print("dealloc ViewModel")
    }
    
    init() {}
    let disposeBag = DisposeBag()
    
    var result: Variable<String> = Variable.init("")
    
    func update() {

        // fetch後結果が出たと仮定
        // self.result.value = "success!!"
        

        // もしFetch用のクラスが別に用意されている場合は
        // そのクラスのfuncからObservableを返済値としてもらって使う
        API.fetch()
            .subscribe(onNext: { (result) in
                self.result.value = result
            })
            .disposed(by: disposeBag)
    }
}

class API {
    static func fetch() -> Observable<String> {
        
        return Observable.create { (observer) -> Disposable in
            // ここでFetch　→　Fetch結果が出たらonNext, onError, onCompletedを利用して返す
            observer.onNext("result desu!")
            observer.onCompleted()
//            observer.onError(<#T##error: Error##Error#>)
            return Disposables.create()
        }
    }
}
