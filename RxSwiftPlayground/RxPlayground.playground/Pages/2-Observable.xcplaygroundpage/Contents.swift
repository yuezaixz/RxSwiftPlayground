//: [Previous](@previous)

/*:
 
 # Observable
 
 ## 什么是Observable
 
 An Observable is an entity that wraps a value and allows to observe the value for changes
 
 Observable就是能够包装一个value的实体，那这个包装什么作用呢？它提供我们订阅这个value更新的机制。也就是一个Push-Driven事件模型。
 
 ## 核心
 
 - 具备observe closure管理功能的泛型容器。RxSwif为我们提供了多种Observable、Subject。
 - 几个操作该容器的核心方法（subscribe/bind/map/filter等）
 
 */

import Foundation

typealias SignalToken = Int

var currentSignalToken: SignalToken = 0

public class Observable<Element>: NSObject {
    
    typealias Subscriber = (Element) -> Void
    
    private var subscriber = [SignalToken : Subscriber]()
    public private(set) var value: Element?
    
    init(value: Element?) {
        self.value = value
    }
    
    func subscribeNext(_ subscriberFunc : @escaping (Element) -> Void) -> SignalToken {
        currentSignalToken += 1
        subscriber[currentSignalToken] = subscriberFunc
        return currentSignalToken
    }
    
    func onNext(_ value: Element) {
        for subscriberFunc in subscriber.values {
            subscriberFunc(value)
        }
    }
    
}

let a = Observable(value: 0)

a.subscribeNext { item in
    print("订阅1:\(item)")
}

a.onNext(1)
a.onNext(2)

a.subscribeNext { item in
    print("订阅2:\(item)")
}

a.onNext(3)
a.onNext(4)
a.onNext(5)

//订阅1:1
//订阅1:2
//订阅2:3
//订阅1:3
//订阅2:4
//订阅1:4
//订阅2:5
//订阅1:5


/*:
 
 ## 操作符：
 
 - filter
 - map
 
 */

extension Observable {
    public func map<Target>(f: @escaping (Element) -> Target) -> Observable<Target> {
        let mappedValue = Observable<Target>(value: nil)
        
        _ = self.subscribeNext({ item in
            mappedValue.onNext(f(item))
        })
        
        return mappedValue
    }
    
    public func filter(f: @escaping (Element) -> Bool) -> Observable<Element> {
        let mappedValue = Observable<Element>(value: self.value)
        
        _ = self.subscribeNext({ item in
            if f(item) {
                mappedValue.onNext(item)
            }
        })
        
        return mappedValue
    }
}

let b = a.filter { $0 > 8 }
let c = b.map { "转换后:\($0)" }
b.subscribeNext { item in
    print("filter后订阅:\(item)")
}
c.subscribeNext { item in
    print("map后订阅:\(item)")
}
a.onNext(6)
a.onNext(7)
a.onNext(8)
a.onNext(9)
a.onNext(10)
a.onNext(11)
a.onNext(12)
a.onNext(13)

//map后订阅:转换后:9
//filter后订阅:9
//map后订阅:转换后:10
//filter后订阅:10
//map后订阅:转换后:11
//filter后订阅:11
//map后订阅:转换后:12
//filter后订阅:12
//map后订阅:转换后:13
//filter后订阅:13

/*:
 
 ## 其他
 
 - 可消除包
 - Schduler
 
 */

//: ![](https://user-gold-cdn.xitu.io/2020/6/14/172b1adc306c0c30?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

//: [Next](@next)
