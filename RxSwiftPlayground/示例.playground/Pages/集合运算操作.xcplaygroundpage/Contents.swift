//: [Previous](@previous)
import RxCocoa
import RxSwift
/*:
### Aggregate Operators，集合运算
我们可以对事件序列做一些集合运算。
*/

/*:
#### concat
concat 可以把多个事件序列合并起来，当前一个complete后，才会接收第二个。[时序图](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/assets/WhichOperator/Operators/concat.png)
*/
example("concat") { () -> () in
    let var1 = BehaviorSubject(value: 0)
    let var2 = BehaviorSubject(value: 200)
    
    // var3 相当于 Observable<Observable<Int>>
    let var3 = BehaviorSubject(value: var1)
    
    _ = var3
        .concat()
        .subscribe {
            print($0)
    }
    var1.on(.next(1))
    var1.on(.next(2))
    var1.on(.next(3))
    var1.on(.next(4))
    
    var3.on(.next(var2))
    
    var2.on(.next(201))
    
    var1.on(.next(5))
    var1.on(.next(6))
    var1.on(.next(7))
    var1.on(.completed)
    
    var2.on(.next(202))
    var2.on(.next(203))
    var2.on(.next(204))
    /**
    ---concat example ---
    Next(0)
    Next(1)
    Next(2)
    Next(3)
    Next(4)
    Next(5)
    Next(6)
    Next(7)
    Next(201)
    Next(202)
    Next(203)
    Next(204)
    */
}


/*:
#### reduce
这里的 reduce 和 CollectionType 中的 reduce 是一个意思，都是指通过对一系列数据的运算最后生成一个结果。
*/
example("reduce") { () -> () in
    _ = Observable.of(0, 1, 2, 3, 4, 5)
        .reduce(0) { $0 + $1 }
        .subscribe {
            print($0)
    }
    /**
    ---reduce example ---
    Next(15)
    Completed
    */
}

//: [Next](@next)
