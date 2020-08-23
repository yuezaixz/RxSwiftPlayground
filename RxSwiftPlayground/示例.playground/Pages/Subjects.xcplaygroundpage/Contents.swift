/*:
 ----
 [Previous](@previous)
 */
import RxSwift
import RxCocoa
/*:
 # Working with Subjects
 Subject 是一个桥梁或者代理，在 Rx 的某些实现里可见，它同时扮演了观察者和 `Observable` 的角色。因为它是一个观察者，所以它可以订阅一个或多个Observables，因为它又是一个Observable，所以它可以回收它自己观察的 item，还可以发出新的 items。
 Observable像是一个水管，会源源不断的有水冒出来。Subject就像一个水龙头，它可以套在水管上，接受Observable上面的事件。但是作为水龙头，它下面还可以被别的observer给subscribe了。[More info](http://reactivex.io/documentation/subject.html)
*/
extension ObservableType {
    /// 快速观察者，id为编号，方便查看
    func addObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
    
}

func writeSequenceToConsole<O: ObservableType>(name: String, sequence: O) -> Disposable {
    return sequence.subscribe { event in
        print("Subscription: \(name), event: \(event)")
    }
}

/*:
 /// 以上两段代码只是辅助理解，方便测试。
 */


/*:
 ## PublishSubject
 在所有的观察者订阅之后广播新的事件。意思是说，每个观察者只能观察到在自己订阅之后 `Observable` 发出的事件。
 [时序图](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png)
 */
example("PublishSubject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*:
 > Tips: 这个例子还介绍了使用 ```onNext(_:)``` 便利方法，这个方法相当于 ```on(.next(_:))``` 方法，这两个方法会导致一个提供element的新事件被发散到订阅者们上。还有```onError(_:)```和```onCompleted()```便利方法，分别相当于```on(.error(_:))```方法和```on(.completed)```方法。

 ----
 ## ReplaySubject
 可以理解为由缓存的PublishSubject，广播新事件到所有的订阅者们上，并且可以把 指定bufferSize数量的在新订阅者订阅之前广播的事件发送到新订阅者上。[时序图](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
*/
example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}
/*:
 ----
## BehaviorSubject
可以理解为带默认值的 "PublishSubject"，广播新的事件到所有的订阅者们上，并且首先发送最近的一个（或者默认的）值到订阅者们上，然后再发送订阅之后的事件。[时序图](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)
*/
example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorSubject(value: "🔴")
    
    subject.addObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.addObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
    
    subject.addObserver("3").disposed(by: disposeBag)
    subject.onNext("🍐")
    subject.onNext("🍊")
}
/*:
 > 注意到在前面这些例子中少了些什么吗？一个 Completed 事件。当PublishSubject，ReplaySubject和BehaviorSubject即将被处理的时候，它们不会自动发出 Completed 事件。
*/

/*:
 ----
## BehaviorRelay
可以理解为带默认值，且不会有error的 "PublishSubject"，有点像RxSwift4之前的Variable，以它将首先发送最近的一个（或者默认的）值到新的订阅者们然后再发送订阅之后的事件。并且BehaviorRelay还会维护当前值的状态。BehaviorRelay不会发出 Error和Complete，所以他用accept发生事件 事件。[时序图](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)
*/
example("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let subject = BehaviorRelay<String>(value: "🔴")
    subject.addObserver("1").disposed(by: disposeBag)
    subject.accept("🐱")
//
    subject.addObserver("2").disposed(by: disposeBag)
    subject.accept("🅰️")
    subject.accept("🅱️")

    subject.addObserver("3").disposed(by: disposeBag)
    subject.accept("🍐")
    subject.accept("🍊")
}

//: [Next](@next) - [Table of Contents](Table_of_Contents)
