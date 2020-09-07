//: [Previous](@previous)

import RxSwift
import RxCocoa
import UIKit

/*:
 # 自定义DelegateProxy
 - `applicationWillResignActive` 方法：在应用从活动状态进入非活动状态的时候会被调用（比如电话来了）。

 - `applicationWillTerminate`方法：在应用终止的时候会被调用。

   过去我们通常都是在 `AppDelegate.swift` 里的相关回调方法中编写相应的业务逻辑。但一旦功能复杂些，这里就会变得十分混乱难以维护。而且有时想在其它模块中使用这些回调也不容易。

   本文演示如何通过对 `UIApplication` 进行 `Rx` 扩展，利用 `RxSwift` 的 `DelegateProxy` 实现 `UIApplicationDelegate` 相关回调方法的封装。从而让 `UIApplicationDelegate` 回调可以在任何模块中都可随时调用。
 ## 监测应用生命周期的状态变化

 ### 1，准备工作

 （1）`RxUIApplicationDelegateProxy.swift`

 首先我们继承 `DelegateProxy` 创建一个关于应用生命周期变化的代理委托，同时它还要遵守 `DelegateProxyType`、`UIApplicationDelegate` 协议。
 */

public class RxUIApplicationDelegateProxy:
    DelegateProxy<UIApplication, UIApplicationDelegate>,
    UIApplicationDelegate, DelegateProxyType {
    
    public weak private(set) var application: UIApplication?
    
    init(application: ParentObject) {
        
        self.application = application
        super.init(parentObject: application, delegateProxy: RxUIApplicationDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register{ RxUIApplicationDelegateProxy(application: $0) }
    }
    
    public static func currentDelegate(for object: UIApplication) -> UIApplicationDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: UIApplicationDelegate?, to object: UIApplication) {
        
        object.delegate = delegate
    }
    
    public override func setForwardToDelegate(_ delegate: UIApplicationDelegate?, retainDelegate: Bool) {
        
        super.setForwardToDelegate(delegate, retainDelegate: true)
    }
    
}

/*:
 （2）`UIApplication+Rx.swift`

 接着我们对 `UIApplication` 进行 `Rx` 扩展，作用是将 `UIApplication` 与前面创建的代理委托关联起来，将状态变化相关的 `delegate` 方法转为可观察序列。

 注意1：我们在开头自定义了一个表示应用状态枚举（`AppState`），不使用系统自带的的 `UIApplicationState` 是因为后者没有 `terminated`（终止）这个状态。

 注意2：下面代码中将 `methodInvoked` 方法替换成 `sentMessage` 其实也可以：
 */
public enum AppState {
    case active
    case inactive
    case background
    case terminated
}

//扩展
extension UIApplication.State {
    func toAppState() -> AppState {
        switch self {
        case .active:
            return .active
        case .inactive:
            return .inactive
        case .background:
            return .background
        default:
            return .terminated
        }
    }
}

extension Reactive where Base: UIApplication {
    
    //代理委托
    var delegate: DelegateProxy<UIApplication, UIApplicationDelegate> {
        return RxUIApplicationDelegateProxy.proxy(for: base)
    }
    
    //应用重新回到活动状态
    var didBecomActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidBecomeActive(_:)))
            .map{ _ in return .active}
    }
    
    //应用从活动状态进入非活动状态
    var willResignActive: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillResignActive(_:)))
            .map{ _ in return .inactive}
    }
    
    //应用从后台恢复至前台（还不是活动状态）
    var willEnterForeground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillEnterForeground(_:)))
            .map{ _ in return .inactive }
    }
    
    //应用进入到后台
    var didEnterBackground: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationDidEnterBackground(_:)))
            .map{ _ in return .background }
    }
    
    //应用终止
    var willTerminate: Observable<AppState> {
        return delegate.methodInvoked(#selector(UIApplicationDelegate.applicationWillTerminate(_:)))
            .map{ _ in return .terminated }
    }
    
    var state: Observable<AppState> {
        return Observable.of(
            didBecomActive,
            willResignActive,
            willEnterForeground,
            didEnterBackground,
            willTerminate
        )
        .merge()
            .startWith(base.applicationState.toAppState())  //为了让开始订阅是就能获取到当前状态
    }
}
//: [Next](@next)
