//: [Previous](@previous)

import RxSwift
import RxCocoa

protocol MTViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class MTBaseViewModel: NSObject {
    lazy var disposeBag = DisposeBag()
    
    deinit {
        print("\(type(of: self)): Deinited")
    }
}

class MTXxViewModel: MTBaseViewModel, MTViewModelType {
    
    
    // MARK: - vars
    private let xxxCode: String
    
    // MARK: - Input
    
    struct Input {
        // 刷新的信号
        let refresh: Observable<Void>
        // tableView的滑动信号
        let contentOffset: Observable<CGPoint>
        // Header部分的展开
        let headerHeight: Observable<CGFloat>
        // 只是CGFloat参数，传入ViewModel用于计算
        let bgImageViewHeight: CGFloat
        // tableView结束拖动的信号
        let didEndDragging: Observable<Bool>
    }
    
    // MARK: - Output

    struct Output {
        let name: Driver<String?>
        let makeTime: Driver<String?>
        let userName: Driver<String?>
        let userNameHidden: Driver<Bool>
        let avatarImageHidden: Driver<Bool>
        let cookThirdHidden: Driver<Bool>
        let cookThirdHeight: Driver<CGFloat>
        let cootThirdTop: Driver<CGFloat>
        let cookBookDesc: Driver<String?>
    }
    
    // MARK: - init

    init(xxxCode: String) {
        self.xxxCode = xxxCode
        super.init()
    }
    
    // MARK: - transform
    
    func transform(input: Input) -> Output {
        
        // input 转换为 Output的逻辑
        
        let stringOutput = Observable<String?>.just("").asDriver(onErrorJustReturn: "")
        let boolOutput = Observable<Bool>.just(false).asDriver(onErrorJustReturn: false)
        let floatOutput = Observable<CGFloat>.just(0.0).asDriver(onErrorJustReturn: 0.0)
        
        return Output(
            name: stringOutput,
            makeTime: stringOutput,
            userName: stringOutput,
            userNameHidden: boolOutput,
            avatarImageHidden: boolOutput,
            cookThirdHidden: boolOutput,
            cookThirdHeight: floatOutput,
            cootThirdTop: floatOutput,
            cookBookDesc: stringOutput
        )
    }
}

//: [Next](@next)
