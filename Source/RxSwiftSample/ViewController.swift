//
//  ViewController.swift
//  RxSwiftSample
//
//  Created by キム ギボン on 2017/08/03.
//  Copyright © 2017年 キム ギボン. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - IBAction
extension ViewController {
    @IBAction func acFetch(_ sender: Any) {
        viewmodel.update()
    }
}

/// VC - VM関係性用のテストクラス
class ViewController: UIViewController {

    deinit {
        print("dealloc ViewController")
    }

    @IBOutlet weak var button: UIButton!
    
    fileprivate let viewmodel = ViewModel()
    let dispose = DisposeBag() // オブジェクトが解除される時Observeも解除されるため

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindVM()
    }
}


// MARK: - Private

extension ViewController {
    fileprivate func bindVM() {
        
        viewmodel.result.asObservable()
            .subscribe(onNext: { (value) in
                print("value >> \(value)")
            })
            .addDisposableTo(dispose)
        
//        button.rx.controlEvent(UIControlEvents.touchUpInside)
//            .subscribe(onNext: { (_) in
//                print("tapped!!")
//            })
//            .addDisposableTo(dispose)
    }
}

