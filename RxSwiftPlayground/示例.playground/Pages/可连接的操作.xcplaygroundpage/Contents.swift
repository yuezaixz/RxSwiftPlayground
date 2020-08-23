//: [Previous](@previous)

import RxSwift

// PLAYGROUND 延时运行
playgroundShouldContinueIndefinitely()
/*:
# Connectable Operators
 可连接的Observable序列类似于普通的Observable序列，除了当它们被订阅后一开始不发散元素，只有当它们的connect方法被调用才会发散元素。这样，你可以等待所有的订阅者在可连接的Observable序列开始发散元素之前订阅它。
 可连接的序列（Connectable Observable）：
 （1）可连接的序列和一般序列不同在于：有订阅时不会立刻开始发送事件消息，只有当调用 connect()之后才会开始发送值。
 （2）可连接的序列可以让所有的订阅者订阅后，才开始发出事件消息，从而保证我们想要的所有订阅者都能接收到事件消息。
 #
 在学习关于可连接的Observable序列的知识之前，让我看一个不是可连接的操作:
*/
func sampleWithoutConnectableOperators() {
    printExampleHeader(#function)
    
    let interval = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    
    _ = interval
        .subscribe(onNext: { print("Subscription: 1, Event: \($0)") })
    
    delay(5) {
        _ = interval
            .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
    }
}

//sampleWithoutConnectableOperators() // ⚠️ 取消注释来运行，注释来停止运行
/*:
 > 在指定的调度程序之上，interval(间隔)创建一个Observable序列并且在每个period(周期)之后发散元素。 [More info](http://reactivex.io/documentation/operators/interval.html)
 [时序图](http://reactivex.io/documentation/operators/images/interval.c.png)
 ![](http://reactivex.io/documentation/operators/images/interval.c.png)
 ----
 ## `publish`
 把源Observable序列转换成一个可连接的Observable序列。 [More info](http://reactivex.io/documentation/operators/publish.html)
 [时序图](http://reactivex.io/documentation/operators/images/publishConnect.c.png)
 ![](http://reactivex.io/documentation/operators/images/publishConnect.c.png)
 */
func sampleWithPublish() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .publish()
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

//sampleWithPublish() // ⚠️ 取消注释来运行，注释来停止运行

//: > 调度程序作为一个抽象机制来执行工作,比如在特定线程或调度队列. [More info](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md)

/*:
 ----
 ## `replay`
 把源Observable序列转换成一个可连接的Observable序列，并且将重复发散bufferSize次。 [More info](http://reactivex.io/documentation/operators/replay.html)
 [时序图](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replay.png)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replay.png)
 */
func sampleWithReplayBuffer() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .replay(5)
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(8) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }

//    --- sampleWithReplayBuffer() example ---
//    Subscription 1:, Event: 0
//    Subscription 2:, Event: 0
//    Subscription 1:, Event: 1
//    Subscription 2:, Event: 1
//    Subscription 1:, Event: 2
//    Subscription 2:, Event: 2
//    Subscription 1:, Event: 3
//    Subscription 2:, Event: 3
//    Subscription 1:, Event: 4
//    Subscription 2:, Event: 4
//    Subscription 3:, Event: 0
//    Subscription 3:, Event: 1
//    Subscription 3:, Event: 2
//    Subscription 3:, Event: 3
//    Subscription 3:, Event: 4 //缓存的5个
//    Subscription 1:, Event: 5
//    Subscription 2:, Event: 5
//    Subscription 3:, Event: 5
//    Subscription 1:, Event: 6
//    Subscription 2:, Event: 6
//    Subscription 3:, Event: 6
//    Subscription 1:, Event: 7
//    Subscription 2:, Event: 7
//    Subscription 3:, Event: 7
//    Subscription 1:, Event: 8
//    Subscription 2:, Event: 8
//    Subscription 3:, Event: 8
//    Subscription 1:, Event: 9
//    Subscription 2:, Event: 9
//    Subscription 3:, Event: 9

}

// sampleWithReplayBuffer() // ⚠️ 取消注释来运行，注释来停止运行

/*:
 ----
 ## `multicast`
 把源Observable序列转换成一个可连接的Observable序列，并通过指定的subject广播发散
 */
func sampleWithMulticast() {
    printExampleHeader(#function)
    
    let subject = PublishSubject<Int>()
    
    _ = subject
        .subscribe(onNext: { print("Subject: \($0)") })
    
    let intSequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .multicast(subject)
    
    _ = intSequence
        .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 3:, Event: \($0)") })
    }
    

//    --- sampleWithMulticast() example ---
//    Subject: 0
//        Subscription 1:, Event: 0
//    Subject: 1
//        Subscription 1:, Event: 1
//        Subscription 2:, Event: 1
//    Subject: 2
//        Subscription 1:, Event: 2
//        Subscription 2:, Event: 2
//    Subject: 3
//        Subscription 1:, Event: 3
//        Subscription 2:, Event: 3
//        Subscription 3:, Event: 3
//    Subject: 4
//        Subscription 1:, Event: 4
//        Subscription 2:, Event: 4
//        Subscription 3:, Event: 4
//    Subject: 5
//        Subscription 1:, Event: 5
//        Subscription 2:, Event: 5
//        Subscription 3:, Event: 5
//    Subject: 6
//        Subscription 1:, Event: 6
//        Subscription 2:, Event: 6
//        Subscription 3:, Event: 6
//    Subject: 7
//        Subscription 1:, Event: 7
//        Subscription 2:, Event: 7
//        Subscription 3:, Event: 7
//    Subject: 8
//        Subscription 1:, Event: 8
//        Subscription 2:, Event: 8
//        Subscription 3:, Event: 8

}

//sampleWithMulticast() // ⚠️ 取消注释来运行，注释来停止运行


//: [Next](@next)
