//: Playground - noun: a place where people can play
import RxSwift
import RxCocoa

/*:
### Combining
这部分是关于序列的运算，可以将多个序列源进行组合拼装成一个新的事件序列。
#### startWith
startWith 会在队列开始之前插入一个事件元素。
*/
example("startWith") {
    
    _ = Observable.of(4, 5, 6)
        .startWith(3)
        .startWith(2)
        .subscribe {
            print($0)
    }
    /**
    *  --- startWith example ---
    Next(2)
    Next(3)
    Next(4)
    Next(5)
    Next(6)
    Completed
    */
}

/*:
#### combineLatest
如果存在两条事件队列，需要同时监听，那么每当有新的事件发生的时候，combineLatest 会将每个队列的最新的一个元素进行合并。
*/
example("combineLatest") { () -> () in
    let stringOb = PublishSubject<String>()
    let intOb = PublishSubject<Int>()
    
    _ = Observable.combineLatest(stringOb, intOb) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
    }
    stringOb.on(.next("A"))
    intOb.on(.next(1))
    stringOb.on(.next("B"))
    intOb.on(.next(2))
    /**
    ---combineLatest example ---
    Next(A 1)
    Next(B 1)
    Next(B 2)
    */
}

example("combineLatest 2") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3, 4)
    
    _ = Observable.combineLatest(intOb1, intOb2) {
        $0 * $1
        }
        .subscribe {
            print($0)
    }
    /**
    ---combineLatest 2 example ---
    Next(0)
    Next(2)
    Next(4)
    Next(6)
    Next(8)
    Completed
    */
}

example("combineLatest 3") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3)//每次都是用的3
    let intOb3 = Observable.of(0, 1, 2, 3, 4)
    
    Observable.combineLatest(intOb1, intOb2, intOb3).map {
        ($0 + $1) * $2
        }
        .subscribe {
            print($0)
    }
    /**
    ---combineLatest 3 example ---
    next(0)
    next(0)
    next(3)
    next(4)
    next(8)
    next(10)
    next(15)
    next(20)
    completed
    */
}

example("combineLatest 4") {
    let intOb = Observable.just(2)
    let stringOb = Observable.just("a")
    
    _ = Observable.combineLatest(intOb, stringOb) {
        "\($0) " + $1
        }
        .subscribe {
            print($0)
    }
    /**
    *  ---combineLatest 4 example ---
    Next(2 a)
    Completed
    */
}

example("combineLatest 5") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3)
    let intOb3 = Observable.of(0, 1, 2, 3, 4)
    
    _ = Observable
        .combineLatest([intOb1, intOb2, intOb3]).map { intArray -> Int in
        Int((intArray[0] + intArray[1]) * intArray[2])
        }
        .subscribe { (event: Event<Int>) -> Void in
            print(event)
    }
    /**
    ---combineLatest 5 example ---
    next(0)
    next(0)
    next(3)
    next(4)
    next(8)
    next(10)
    next(15)
    next(20)
    completed
    */
}


/*:
#### zip
zip 人如其名，就是合并两条队列用的，不过它会等到两个队列的元素一一对应地凑齐了之后再合并，正如百折不撓的米斯特菜所提醒的， zip 就像是拉链一样，两根拉链拉着拉着合并到了一根上：
*/
example("zip 1") { () -> () in
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()
    
    _ = Observable.zip(intOb1, intOb2) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
    }
    
    intOb1.on(.next("A"))
    
    intOb2.on(.next(1))
    
    intOb1.on(.next("B"))
    
    intOb1.on(.next("C"))
    
    intOb2.on(.next(2))
    /**
    ---zip 1 example ---
    Next(A 1)
    Next(B 2)
    */
}

example("zip 2") {
    let intOb1 = Observable.just(2)
    
    let intOb2 = Observable.of(0, 1, 2, 3, 4)
    
    _ = Observable.zip(intOb1, intOb2) {
        $0 * $1
        }
        .subscribe {
            print($0)
    }
    /**
    ---zip 2 example ---
    Next(0)
    Completed
    */
}

example("zip 3") {
    let intOb1 = Observable.of(0, 1)
    let intOb2 = Observable.of(0, 1, 2, 3)
    let intOb3 = Observable.of(0, 1, 2, 3, 4)
    
    _ = Observable.zip(intOb1, intOb2, intOb3) {
        ($0 + $1) * $2
        }
        .subscribe {
            print($0)
    }
    /**
    ---zip 3 example ---
    Next(0)
    Next(2)
    Completed
    */
}

/*:
#### marge
merge 就是 merge 啦，把两个队列按照顺序组合在一起。
*/
example("merge 1") { () -> () in
    let disposeBag = DisposeBag()
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()
    
    Observable.of(subject1, subject2)
        .merge()
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    subject1.on(.next(20))
    subject1.on(.next(40))
    subject1.on(.next(60))
    subject2.on(.next(1))
    subject1.on(.next(80))
    subject1.on(.next(100))
    subject2.on(.next(1))
    
    /**
    ---merge 1 example ---
    20
    40
    60
    1
    80
    100
    1
    */
}

example("merge 2") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()
    
    _ = Observable.of(subject1, subject2)
        .merge(maxConcurrent: 2)
        .subscribe {
            print($0)
    }
    
    subject1.on(.next(20))
    subject1.on(.next(40))
    subject1.on(.next(60))
    subject2.on(.next(1))
    subject1.on(.next(80))
    subject1.on(.next(100))
    subject2.on(.next(1))
    /**
    ---merge 2 example ---
    Next(20)
    Next(40)
    Next(60)
    Next(1)
    Next(80)
    Next(100)
    Next(1)
    */
}


/*:
#### switchLatest
当你的事件序列是一个事件序列的序列 (Observable<Observable<T>>) 的时候，（可以理解成二维序列？），可以使用 switch 将序列的序列平铺成一维，并且在出现新的序列的时候，自动切换到最新的那个序列上。和 merge 相似的是，它也是起到了将多个序列『拍平』成一条序列的作用。
*/
example("switchLatest") { () -> () in
    let var1 = BehaviorRelay(value: 0)
    let var2 = BehaviorRelay(value: 200)
    
    // var3 类似 Observable<Observable<Int>>
    let var3 = BehaviorRelay(value: var1.asObservable());
    _ = var3
        .asObservable()
        .switchLatest()
        .subscribe() {
            print($0)
    }
    
    var1.accept(1)
    var1.accept(2)
    var1.accept(3)
    var1.accept(4)
    
    var3.accept(var2.asObservable())
    
    var2.accept(201)
    var1.accept(5)
    var1.accept(6)
    var1.accept(7)
    /**
    ---switchLatest example ---
    Next(0)
    Next(1)
    Next(2)
    Next(3)
    Next(4)
    Next(200)
    Next(201)
    // BehaviorRelay 没有 Completed
    */
}
