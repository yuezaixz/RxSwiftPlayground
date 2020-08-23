//: [Previous](@previous)

import RxSwift
import RxCocoa

/*:
### 3. Filtering and Conditional Operators
 过滤和条件操作
 
 RxSwift有非常多操作符，如下列举了很多常见的，

 filter
 distinctUntilChanged
 elementAt
 single
 single
 take
 takeLast
 takeWhile
 takeUntil
 skip
 skipWhile
 skipWhileWithIndex
 skipUntil
 
 但这里只对take filter distinctUntilChanged举例介绍。
 [具体可以在这里查看](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree.html)
 
*/


/*:
### Filtering
除了上面的各种转换，我们还可以对序列进行过滤。
#### filter
filter 只会让符合条件的元素通过。
*/
example("filter") {
    
    let subscription = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        .filter {
            $0 % 2 == 0
        }
        .subscribe {
            print($0)
    }
}



/*:
#### distinctUntilChanged
distinctUntilChanged 会废弃掉相邻的重复事件。
*/
example("distinctUntilChanged") {
    let subscription = Observable.of(1, 2, 3, 1, 1, 4)
        .distinctUntilChanged()
        .subscribe {
            print($0)
    }
    /**
    *  --- distinctUntilChanged example ---
    Next(1)
    Next(2)
    Next(3)
    Next(1)
    Next(4)
    Completed
    */
}

/*:
#### take
take 只获取序列中的前 n 个事件，在满足数量之后会自动 .completed 。
*/
example("take") { () -> () in
    let subscription = Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe {
            print($0)
    }
    /**
    *  --- take example ---
    Next(1)
    Next(2)
    Next(3)
    Completed
    */
}



//: [Next](@next)


//: [Next](@next)
