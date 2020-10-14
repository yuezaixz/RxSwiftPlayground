//: [Previous](@previous)

import RxSwift
import RxCocoa
import Foundation

let disposeBag = DisposeBag()

var fetchTriger = PublishRelay<Void>()
var fetchTrigerSwitch = BehaviorRelay<Observable<Void>>(value: fetchTriger.asObservable())
fetchTrigerSwitch
    .flatMapLatest{ $0 }
    .flatMap { _ -> Observable<Int> in
        print("\(Int(Date().timeIntervalSince1970))")
        if Int(Date().timeIntervalSince1970) % 3 == 0 {
            fetchTrigerSwitch.accept(Observable.never())
            return Observable.of(1, 2, 3, 4, 5)
        } else {
            // 处理错误
            return Observable.empty()
    //        return Observable.error(NSError(domain: "HC", code: -1, userInfo: [NSLocalizedDescriptionKey : "ObjectMapper can't mapping Object"]))
        }
    }
    .catchError({ error -> Observable<Int> in
        print("\(error.localizedDescription)")
        return Observable.empty()
    })
    .subscribe(onNext: { item in
        print("收到:\(item)")
    }).disposed(by: disposeBag)

for _ in 0 ..< 11 {
    fetchTriger.accept(())
    sleep(1)
}

//: [Next](@next)
