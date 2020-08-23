//: [Previous](@previous)
import RxSwift
import RxCocoa

/*:
### Error Handling
在事件序列中，遇到异常也是很正常的事情，有以下几种处理异常的手段。
*/

/*:
#### catchError
catchError 可以捕获异常事件，并且在后面无缝接上另一段事件序列，丝毫没有异常的痕迹。
*/
example("catchError 1") { () -> () in
    let sequenceThatFails = PublishSubject<Int>()
    let recoverySequece = Observable.of(100, 200, 300, 400)
    
    _ = sequenceThatFails
        .catchError { error in
            // 出错的情况，替换成另一个事件。
            // 比如网络错误什么的情况，替换成缓存或者其他
            return recoverySequece
        }
        .subscribe() {
            print($0)
    }
    
    sequenceThatFails.on(.next(1))
    sequenceThatFails.on(.next(2))
    sequenceThatFails.on(.next(3))
    sequenceThatFails.on(.next(4))
    sequenceThatFails.on(.error(NSError(domain: "Test", code: 0, userInfo: nil)))
    /**
    ---catchError 1 example ---
    Next(1)
    Next(2)
    Next(3)
    Next(4)
    Next(100)
    Next(200)
    Next(300)
    Next(400)
    Completed
    */
}

example("catchError 2") {
    let sequenceThatFails = PublishSubject<Int>()
    
    _ = sequenceThatFails
        // 最常用的，出错的情况，用某个默认值，保证业务正常运行
        .catchErrorJustReturn(100)
        .subscribe {
            print($0)
    }
    
    sequenceThatFails.on(.next(1))
    sequenceThatFails.on(.next(2))
    sequenceThatFails.on(.next(3))
    sequenceThatFails.on(.next(4))
    sequenceThatFails.on(.error(NSError(domain: "Test", code: 0, userInfo: nil)))
}


/*:
#### retry
retry 顾名思义，就是在出现异常的时候会再去从头订阅事件序列，妄图通过『从头再来』解决异常。
*/
example("retry") { () -> () in
    var count = 1 // bad practice, only for example purposes
    let funnyLookingSequence = Observable<Int>.create { observer in
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        observer.on(.next(0))
        observer.on(.next(1))
        observer.on(.next(2))
        if count < 2 {
            observer.on(.error(error))
            count += 1
        }
        observer.on(.next(3))
        observer.on(.next(4))
        observer.on(.next(5))
        observer.on(.completed)
        
        return Disposables.create()
    }
    
    _ = funnyLookingSequence
        .retry()
        .subscribe {
            print($0)
    }
    /**
    ---retry example ---
    Next(0)
    Next(1)
    Next(2)
    Next(0)
    Next(1)
    Next(2)
    Next(3)
    Next(4)
    Next(5)
    Completed
    */
}


//: [Next](@next)
