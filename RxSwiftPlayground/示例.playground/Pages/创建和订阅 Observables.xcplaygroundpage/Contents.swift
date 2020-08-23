/*:
----
[Previous](@previous)
*/
import RxSwift
/*:
 # 创建和订阅 `Observable`s
 这里有以下几种方法来创建和订阅Observable序列
 ## never
 创建一个不会终止和不会发出任何事件的序列 [了解更多](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("never") {
    let disposeBag = DisposeBag()
    let neverSequence = Observable<String>.never()
    
    let neverSequenceSubscription = neverSequence
        .subscribe { _ in
            print("This will never be printed")
    }
    
    neverSequenceSubscription.disposed(by: disposeBag)
}
/*:
 ----
 ## 创建一个空的Observable序列，这个序列仅仅只发出一个 Completed 事件。 [More info](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("empty") {
    let disposeBag = DisposeBag()
    
    Observable<Int>.empty()
        .subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## just
 创建仅有一个元素的Observable序列。 [More info](http://reactivex.io/documentation/operators/just.html)
 */
example("just") {
    let disposeBag = DisposeBag()
    
    Observable.just("🔴")
        .subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## of
 创建具有固定数量元素（参数）的Observable序列。
 */
example("of") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .subscribe(onNext: { element in
            print(element)
        })
        .disposed(by: disposeBag)
}
/*:
 > Tips:这个例子还介绍了怎样使用subscribe(onNext:)便利方法。与subscribe(_:)不同的是，subscribe(_:)方法给所有的事件类型 (Next, Error, Completed) 订阅了一个event（事件）处理者，而subscribe(onNext:)方法则订阅了一个element（元素）处理者，这个element（元素）处理者将会忽略 Error 和 Completed 事件并且只产生 Next 事件元素。还有subscribe(onError:)和subscribe(onCompleted:)便利方法，只要你想订阅这些事件类型。而且还有一个subscribe(onNext:onError:onCompleted:onDisposed:)方法，它允许你对一个或多个事件类型做出反应，而且在单独调用时当因为任何原因，或者被处理，订阅会被终止:
 ```
 someObservable.subscribe(
     onNext: { print("Element:", $0) },
     onError: { print("Error:", $0) },
     onCompleted: { print("Completed") },
     onDisposed: { print("Disposed") }
 )
```
 ----
 ## from
 使用一个Sequence类型的对象创建一个Observable序列，比如一个Array，Dictionary，或者Set
 */
example("from") {
    let disposeBag = DisposeBag()
    
    Observable.from(["🐶", "🐱", "🐭", "🐹"])
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > 注意：这个例子还演示了怎样使用默认参数名$0代替显示命名参数.
----
 ## 创建一个自定义的Observable序列。 [More info](http://reactivex.io/documentation/operators/create.html)
*/
example("create") {
    let disposeBag = DisposeBag()
    
    let myJust = { (element: String) -> Observable<String> in
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }
        
    myJust("🔴")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## range
 创建一个在一定范围发出一系列连续的整数序列然后终止的Observable序列。[More info](http://reactivex.io/documentation/operators/range.html)
 */
example("range") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## repeatElement
 创建一个不确定次数地发出指定元素的Observable序列. [More info](http://reactivex.io/documentation/operators/repeat.html)
 */
example("repeatElement") {
    let disposeBag = DisposeBag()
    
    Observable.repeatElement("🔴")
        .take(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > 注意：这个例子还介绍了使用take操作从一个序列开始取到指定数量的元素
 ----
 ## generate
 创建一个只要条件的值为 `true` 就生成值的Observable序列.
 */
example("generate") {
    let disposeBag = DisposeBag()
    
    Observable.generate(
            initialState: 0,
            condition: { $0 < 3 },
            iterate: { $0 + 1 }
        )
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## deferred
 为每一个订阅者创建一个新的Observable序列。 [More info](http://reactivex.io/documentation/operators/defer.html)
 */
example("deferred") {
    let disposeBag = DisposeBag()
    var count = 1
    
//    let deferredSequence = Observable<String>.deferred {
//        print("Creating \(count)")
//        count += 1
//
//        return Observable.create { observer in
//            print("Emitting...")
//            observer.onNext("🐶")
//            observer.onNext("🐱")
//            observer.onNext("🐵")
//            return Disposables.create()
//        }
//    }
    
    let deferredSequence = Observable<String>.deferred {
        print("Creating \(count)")
        count += 1
        
        return Observable.of("🐶", "🐱", "🐵")
    }
    
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## error
 创建一个不会发散出任何事件或元素并且遇到错误就会立即终止的Observable序列。
 */
example("error") {
    let disposeBag = DisposeBag()
        
    Observable<Int>.error(TestError.test)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## doOn
 为每一个被发出的事件调用一个附带动作并且返回(通过)最初的事件。 [More info](http://reactivex.io/documentation/operators/do.html)
 */
example("doOn") {
    let disposeBag = DisposeBag()
    
    Observable.of("🍎", "🍐", "🍊", "🍋")
        .do(onNext: { print("Intercepted:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
//: > 注意：还有doOnNext(_:),doOnError(_:),和doOnCompleted(_:)拦截特定事件的便利方法，而且doOn(onNext:onError:onCompleted)方法在单独调用时可以拦截一个或多个事件。

//: [Next](@next)
