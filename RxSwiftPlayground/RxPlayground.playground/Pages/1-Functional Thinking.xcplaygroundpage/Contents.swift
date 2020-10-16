//: [Previous](@previous)

import Foundation

/*:
 
 # 函数式编程
 
 ### 举个例子
 
 他用来在播放某段视频的时候，调用统计API记录这个视频的标题。
 
 ### 看下面这段代码
 
 */

struct MTVideo {
    let title: String?
}

class MTVideoManager {
    
    let videos: [String: MTVideo] = [:]
    
    func startVideoPlay(videoUrl: String?) {
        if let videoUrl = videoUrl {
            if let videoInfo = videos[videoUrl] {
                if let title = videoInfo.title {
                    print(title)
//                    MTAnalytics.event("mtxx_video_play", attributes: ["标题" : title])
                }
            }
        }
    }
    
}

/*:
 ### 心累，想哭
 
 真正的代码就一行统计上报，其他代码全部都在异常处理。
 如果这时候又要添加一个上报的参数呢？又要添加一堆异常处理。
 
 最近刚写的一段代码 [Code](http://techgit.meitu.com/iMeituPic/mtxx/-/blob/feature/puzzle_report_wdw/MTXX/Classes/ViewController/MTXXCosmesis/DenseHair/MTDenseHairProcessor.swift#L178)
 
 
 */

class MTVideoManagerRefactor {
    
    let videos: [String: MTVideo] = [:]
    
    func startVideoPlay(videoUrl: String?) {
        let videoInfo: MTVideo? = videoUrl.flatMap { videoUrl -> MTVideo? in
            return videos[videoUrl]
        }
        let title = videoInfo.flatMap { videoInfo -> String? in
            return videoInfo.title
        }
        title.flatMap { title -> Void in
            print(title)
            return
        }
    }
    
    func startVideoPlayChain(videoUrl: String?) {
        videoUrl.flatMap { videoUrl -> MTVideo? in
            return videos[videoUrl] // 业务逻辑，怎么转换
        }.flatMap { videoInfo -> String? in
            return videoInfo.title // 业务逻辑，需要什么参数
        }.flatMap { title in
            print(title) // 业务逻辑，统计
            // MTAnalytics.event("mtxx_video_play", attributes: ["标题" : title])
        }
    }
    
}

//: 当然，这样可读性很差。可以扩展Optional添加一个标准化的方法来优化下

extension Optional {
    func checkUnwrap<R>(_ bizFunction: (Wrapped) -> R) -> R? {
        self.flatMap { bizFunction($0) }
    }
}

class MTVideoManagerFinish {
    
    let videos: [String: MTVideo] = ["1" : MTVideo(title: "我是标题")]
    
    func startVideoPlayChain(videoUrl: String?) {
        videoUrl
            .checkUnwrap { videos[$0] }? // 业务逻辑，怎么转换
            .checkUnwrap { $0.title }? // 业务逻辑，需要什么参数
            .checkUnwrap { print($0) } // 业务逻辑，统计
    }
    
}

MTVideoManagerFinish().startVideoPlayChain(videoUrl: "1")

//: 我们这里做的主要的事情就是，提供一个标准化的方法，来实现从接受OptionalValue到只接受非Optional Value的转换这个有共用性的函数。
//: 从而将注意力集中在核心的业务逻辑处理上，而不是OptionalValue的校验上

//: RxSwift（RxCocoa及自定义、第三方实现的扩展）一个很大的帮助，也就是让我们将注意力集中在业务逻辑上。举个例子

import RxSwift
import RxCocoa

let disposeBag = DisposeBag()
let pageControl = UIPageControl()
let mainScrollView = UIScrollView()

//: RxCocoa的实现
mainScrollView.rx.contentOffset.subscribe(onNext: { point in
    print("scroll x:\(point.x) y:\(point.y)")
}).disposed(by: disposeBag)

//: 自定义的实现
mainScrollView.rx.currentPage
    .subscribe(onNext: {
        pageControl.currentPage = $0
        // 其他滑到到该页后的业务逻辑
    })
    .disposed(by: disposeBag)

fileprivate extension Reactive where Base: UIScrollView {
    var currentPage: Observable<Int> {
        return didEndDecelerating.map({
            let pageWidth = self.base.frame.width
            let page = floor((self.base.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            return Int(page)
        })
    }
}

/*:
 # 使用RxSwift的理由1：
 # 总结一下RxSwift函数编程的好处
 - 通过抽象来更好的描述问题
 
 > 本质：非确定State -> 确定性 State的转换
 
 - 对于同构的场景提取模型
 
 > ```checkUnwrap```函数，```currentPage```函数

 - 最后通过符合直觉的方式解决问题
 
 > 链式调用，顺序执行，无需维护一堆中间变量和分支逻辑
 
 */

//: [Next](@next)
