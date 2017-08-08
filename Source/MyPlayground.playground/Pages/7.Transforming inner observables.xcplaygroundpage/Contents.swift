
import Foundation
import UIKit
import RxSwift
import RxCocoa


struct Student {
    var score: Variable<Int>
    var name: Variable<String>
}

// 특정 학생의 점수를 지속적으로 감시하고 싶을 때?
// Student라는 struct를 통지하는 Publish를 subscribe함
// 이것을 flatMap을 통해서 Observable형태로 반환하면 이후 감시가 가능함?
// >> 즉 특정 Object의 요소를 flatMap을 통해서 Observable로 반환하면 그 이후부터는 지속적인 감시가 가능해짐.
// 하나의 property만 체크가 가능한 듯..
example(of: "FlatMap") {

    let disposeBag = DisposeBag()

    let ryan = Student.init(score: Variable(80), name: Variable("noname"))
    let charlotte = Student.init(score: Variable(100), name: Variable("noname"))
    
    let student = PublishSubject<Student>()
    
    student.asObserver()
        .flatMap({
            
            $0.score.asObservable() // FlatMap는 Observable로 반환해야함. 왜?
        })
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: disposeBag)
    
    student.onNext(ryan)
    student.onNext(charlotte)
    
    ryan.score.value = 60
    ryan.name.value = "ryan"

    /*
     --- Example of: FlatMap ---
     80
     100
     60
     */
}

example(of: "test2") { 
    var value = Variable<Int>.init(20)
    
    value.asObservable()
        .subscribe(onNext: { (value) in
            print("test")
        })
}

// 첫번째 onNext된 녀석만 반응함
// 이건 언제 쓰나?
example(of: "flatMapLatest") {
    
    let disposeBag = DisposeBag()
    
    let ryan = Student.init(score: Variable(80), name: Variable("noname"))
    let charlotte = Student.init(score: Variable(100), name: Variable("noname"))
    
    let student = PublishSubject<Student>()
    
    student.asObserver()
        .flatMapFirst({
            $0.score.asObservable()
        })
        .subscribe(onNext: { (value) in
            print(value)
        })
        .disposed(by: disposeBag)
    
    student.onNext(charlotte)
    student.onNext(ryan)
    
    ryan.score.value = 60
    charlotte.score.value = 100
    charlotte.score.value = 70
    ryan.score.value = 90
}

// 전화번호 체크!
example(of: "Challenge1") {
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined() // ふぉ
        print("inputed numbers >> \(phone)")
        phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 3))
        phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 7))
        
        return phone
    }

    var contacts: Dictionary<String, Any> = [:]
    let disposeBag = DisposeBag()
    
    // 아마 전화번호부 validation일 듯
    Observable<Int>.of(0,1,2,3,4,5,6,7,9,0,9,8,23123,102)
        .skipWhile { $0 == 0 } // 첫번째에 0이 들어오면 안되고.
        .filter { $0 < 10 } // 0 ~ 9사이의 값만 받고
        .take(10) // 10개만 받음까지만 받음. 다른 조건은 위에서 커트를 하기 때문에 좋음.
        .toArray() // 배열로 만듬.
        .subscribe(onNext: {
            print("\($0)")
            let phone = phoneNumber(from: $0)
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        })
        .disposed(by: disposeBag)
    
    /*
     --- Example of: Challenge1 ---
     [1, 2, 3, 4, 5, 6, 7, 9, 0, 9]
     inputed numbers >> 1234567909
     Contact not found
     */
    
}

example(of: "Challenge2") {

    let convert: (String) -> UInt? = { value in

        if let number = UInt(value), number < 10 {
            return number
        }

        let convert: [String: UInt] = [
            "abc": 2,
            "def": 3,
            "ghi": 4,
            "jkl": 5,
            "mno": 6,
            "pqrs": 7,
            "tuv": 8,
            "wxyz": 9
        ]
        var converted: UInt?
        convert.keys.forEach {
            if $0.contains(value.lowercased()) {
                converted = convert[$0]
            }
        }

        return converted
    }

    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()
        phone.insert ( "-", at: phone.index(
            phone.startIndex,
            offsetBy: 3
            )
        )
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7
            )
        )

        return phone
    }

}





//example(of: "FlatMap sample2") {
//
//    extension ObservableType {
//        func unwrap<R: Optionable>(_ transform: @escaping ((E) -> R)) -> Observable<R.Wrapped> {
//            return flatMap { (element: E) -> Observable<R.Wrapped> in
//                transform(element).flatMap(Observable.just) ?? Observable.empty()
//            }
//        }
//    }
//
//    let disposeBag = DisposeBag()
//    
//    Observable.of(1,2,3,4, nil)
//        .flatMap({ $0 == nil ? Observable.empty() : Observable.just($0) })
//        .subscribe ({
//            print("\($0)")
//        })
//        .disposed(by: disposeBag)
//    
//    Observable.of(1,2,3,4, nil)
//        .unwrap
//        .subscribe ({
//            print("\($0)")
//        })
//    
//}





