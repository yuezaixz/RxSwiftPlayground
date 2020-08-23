//: [Previous](@previous)

import RxSwift
/*:
 # Debugging Operators
 该类操作帮助调试 Rx 代码。
 ## `debug`
 打印出所有订阅,事件和处理。
 */
example("debug") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count < 5 {
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry(3)
        .debug()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## `RxSwift.Resources.total`
 提供了所有Rx资源分配的计算量,它在开发过程中对于检测泄漏是非常有用的。
 */
#if NOT_IN_PLAYGROUND
#else
example("RxSwift.Resources.total") {
    print(RxSwift.Resources.total)
    
    let disposeBag = DisposeBag()
    
    print(RxSwift.Resources.total)
    
    let subject = BehaviorSubject(value: "🍎")
    
    let subscription1 = subject.subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    let subscription2 = subject.subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    subscription1.dispose()
    
    print(RxSwift.Resources.total)
    
    subscription2.dispose()
    
    print(RxSwift.Resources.total)
}
    
print(RxSwift.Resources.total)
#endif
/*:
 ----> `RxSwift.Resources.total` 在默认情况下不启用,通常不会启用发布构建。下面是展示如何启用它：

//: CocoaPods

1. 添加post_install脚本到Podfile文件，比如.:

```
 
target 'AppTarget' do
pod 'RxSwift'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
 
```
 
2. 运行 pod update.
3. 编译.
 
*/

//: [Next](@next)
