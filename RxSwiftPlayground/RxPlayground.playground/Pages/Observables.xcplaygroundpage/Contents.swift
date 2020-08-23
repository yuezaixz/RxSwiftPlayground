import RxSwift
import RxCocoa

/*:
 >  `Observable`相关
 ----
 ## 常用的Observable创建
 常用的创建 `Observable` 方式有just、. [更多信息](http://reactivex.io/documentation/operators.html#creating)
 */
example("just") {
    let disposeBag = DisposeBag()
    
    Observable.just("🔴")
        .subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
}
