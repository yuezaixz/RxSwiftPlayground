//: [Previous](@previous)
import Foundation
import RxSwift
import RxCocoa

/*:
### 3.Transform
我们可以对序列做一些转换，类似于 Swift 中 CollectionType 的各种转换。
*/

/*:
#### map
map 就是对每个元素都用函数做一次转换，挨个映射一遍。
*/
example("map") { () -> () in
    let originalSequence = Observable.of(1, 2, 3)
    
    _ = originalSequence
        .map { $0 * 2 }
        .subscribe{ print($0) }
    /**
    *  --- map example ---
    Next(2)
    Next(4)
    Next(6)
    Completed
    */
}


/*:
#### flatMap
map 在做转换的时候很容易出现『升维』的情况，即：转变之后，从一个序列变成了一个序列的序列。
什么是『升维』？在集合中我们可以举这样一个例子，我有一个好友列表 [p1, p2, p3]，那么如果要获取我好友的好友的列表，可以这样做：
myFriends.map { $0.getFriends() }
结果就成了 [[p1-1, p1-2, p1-3], [p2-1], [p3-1, p3-2]] ，这就成了好友的好友列表的列表了。这就是一个『升维』的例子。
在 Swift 中，我们可以用 flatMap 过滤掉 map 之后的 nil 结果。在 Rx 中， flatMap 可以把一个序列转换成一组序列，然后再把这一组序列『拍扁』成一个序列。
*/
example("flatMap") { () -> () in
    let sequenceInt = Observable.of(1, 2, 3)
    let sequenceString = Observable.of("A", "B", "--")
    
    _ = sequenceInt
        .flatMap { (x:Int) -> Observable<String> in
            print("from sequenceInt \(x)")
            return sequenceString.map{ $0 + "\(x)" }
        }
        .subscribe {
            print($0)
    }
    /**
    *  ---flatMap example ---
    from sequenceInt 1
    next(A1)
    from sequenceInt 2
    next(B1)
    next(A2)
    from sequenceInt 3
    next(--1)
    next(B2)
    next(A3)
    next(--2)
    next(B3)
    next(--3)
    completed
    */
}


/*:
#### scan
scan 有点像 reduce ，它会把每次的运算结果累积起来，作为下一次运算的输入值。
*/
example("scan") {
    let sequenceToSum = Observable.of(0, 1, 2, 3, 4, 5)
    
    _ = sequenceToSum
        .scan(0) { acum, elem in
            acum + elem
        }
        .subscribe {
            print($0)
    }
    /**
    *  --- scan example ---
    Next(0)
    Next(1)
    Next(3)
    Next(6)
    Next(10)
    Next(15)
    Completed
    */
}
