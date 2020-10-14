# RxSwift实例

## 一个简单的需求

![矩形](http://image.runmaf.com/2020-10-14-矩形.jpg)

![](http://image.runmaf.com/2020-10-14-16005924355829.jpg)

<p align="left" >
  <video controls="controls" autoplay="autoplay">
	  <source src="Resources/RPReplay_Final1600610746.MP4"/>
	</video>
</p>

## 快门点击事件

### 方式1 Delegate逐级上传

![](http://image.runmaf.com/2020-10-14-16005940324563.jpg)

需要一层一层的增加Delegate协议，一层一层逐级往上抛

#### 弊端

* boilerplate code 冗余代码
* 一个简单改动需要改N个地方，比如加一个参数

### NotificationCenter

![](http://image.runmaf.com/2020-10-14-16005942211134.jpg)

不需要经过中间的类。

#### 弊端

* 全局NotifacationName
* 耦合性太低，没法反映出逻辑的依赖关系，不易维护

### 方式3 引用

![](http://image.runmaf.com/2020-10-14-16005944134037.jpg)

``` swift

	@objc func shutterTapped() {
        self.view.isUserInteractionEnabled = false
        let parent = self.parent as! CameraActionViewController
        let loadingVC = LoadingViewController()
        if parent.timerEngine.currentTime != 0 { parent.timerEngine.presentTimerDisplay() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(parent.timerEngine.currentTime)) {
            parent.cameraEngine?.captureImage(completion: { [weak self] (capturedImage) in
                guard let self = self, let image = capturedImage else { return }
                parent.cameraEngine?.isCapturing.toggle()
                parent.parent!.addVC(loadingVC)
                
                DispatchQueue.main.async {
                    guard let editedImage = FilterEngine.shared.process(originalImage: image) else { return }
                    
                    guard let editedData = editedImage.jpegData(compressionQuality: 1.0) else { return }
                    DataEngine.shared.save(imageData: editedData)
                    
                    TapticHelper.shared.successTaptic()
                    loadingVC.removeVC()
                    parent.cameraEngine?.isCapturing = false
                }
                self.view.isUserInteractionEnabled = true
            })
        }
    }

```

#### 弊端

* 强耦合
* 太多强制类型转换

### RxSwift方式 - 信号

![](http://image.runmaf.com/2020-10-14-16005963502962.jpg)

#### 优点

* 不是一对一，可以被多个订阅
* 信号相当于接口，依赖的是信号。其他内部的信息都不需要暴露，保证的封闭性
* 新增事件只需要新增一个singnal，中间层不许修改。修改参数也一样
* 依赖关系很清晰，无需维护全局通知列表


> <font color=red style="font-size: 30px;">使用RxSwift的理由2：函数式的响应式编程</font>

使用数据流传播数据的变化，响应这个数据流的计算模型会自动计算出新的值，将新的值通过数据流传给下一个响应的计算模型，如此反复下去，直到没有响应者为止。

### MVVM

![](media/16005717562800/16005966052231.jpg)

* 比Controller更轻量级的处理单元 => ViewModel
* View组件有对应的ViewModel模块为其服务，不再强依赖Controller

<font color=red style="font-size: 30px;">使用RxSwift的理由3：RxSwift解决了ViewModel和View如何交互的问题</font>

#### ViewModel如何设计

``` swift

	// MARK: - Input

    struct Input {
        let selectButtonTapped: Observable<Void>
        let refreshEvent: Observable<Void>
    }
    
    // MARK: - Output

    struct Output {
        let isSelecting: Observable<Bool>
        let selectedImageIndexes: Observable<[IndexPath]>
        let imageObjects: Observable<[SectionModel<String, Photo>]>
    }
    
    func transform(input: Input) -> Output {
        input.selectButtonTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.isSelecting.accept(!self.isSelecting.value)
        }).disposed(by: rx.disposeBag)
        
        input.refreshEvent.flatMapLatest(fetchData).share(replay: 1).bind(to: imageObjects).disposed(by: rx.disposeBag)
        
        return Output(
            isSelecting: isSelecting.asObservable(),
            selectedImageIndexes: selectedImageIndexes.asObservable().skip(1),
            imageObjects: imageObjects.map{ [SectionModel<String, Photo>(model: "", items: $0)] }
        )
    }

```

#### View如何设计

``` swift

private func subscriptViewModel() {
        
        let output = viewModel.transform(
            input: LabCollectionViewModel.Input(
                selectButtonTapped: Observable.merge([deleteOrDownloadSuccess, selectButton.rx.tap.asObservable()]),
                // 这里简单些就是开始的时候加载一次，如果需要按钮点击刷新就refreshButton.rx.tap.asObservable()
                // .startWith(())，或者下拉刷新
                refreshEvent: Observable<Void>.just(())
            )
        )
        output.isSelecting.subscribe(onNext: { [weak self] isSelecting in
            // ... 编辑状态改变的相关UI逻辑
            
        }).disposed(by: rx.disposeBag)
        output.selectedImageIndexes.subscribe(onNext: { [weak self] selectedImageIndexes in
            // ... 选中照片改变的相关UI逻辑
        }).disposed(by: rx.disposeBag)
        output.isSelecting
            .withLatestFrom(output.selectedImageIndexes) { (isSelecting, selectedImageIndexes) -> (Bool, [IndexPath]) in
                (isSelecting, selectedImageIndexes)
            }
            .subscribe(onNext: { [weak self] (isSelecting, selectedImageIndexes) in
                // ... 编辑状态改变相关数据处理UI逻辑
            }).disposed(by: rx.disposeBag)
        
        // 获取到数据后，刷新视图背景
        output.imageObjects.subscribe(onNext: { [weak self] _ in
            // ... 数据刷新时候，更新UI逻辑
        }).disposed(by: rx.disposeBag)
        
let dataSource = RxCollectionViewSectionedReloadDataSource
            <SectionModel<String, Photo>>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabCollectionViewCell.ReuseIdentifier,
                                                for: indexPath) as! LabCollectionViewCell

// ... cell的ui逻辑
                
                return cell
            }
        )
        output.imageObjects.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

```

ViewController再不用关心数据如何加载的了，只需要传递信号出去，然后绑定数据信号到相应的View。

* ViewModel内的数据不管已何种方式更新，View都能得到通知并刷新
* ViewModel是函数式的，只关注自己内部的逻辑如何实现，不需关注使用自己的View，更不需要知道View的细节
* 纯逻辑的ViewModel，非常容易编写单元测试
* ViewController在初始阶段就做完了生命周期的所有事情（声明式编程）

``` swift

	override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel() // 构建ViewModel
        setupUI() // 构建UI
        setupConstraint() // 构建UI自动布局约束
        subscriptViewModel() // 将UI和ViewModel的逻辑处理绑定起来了
    }

```

### 维护难度

产品： 有时候产品会来问，这个需求就几句话，在原来的XXX上就修改一点，为什么要好几天时间开发。

开发： 看起来是这样没错，但之前实现有点复杂，一些回调有些乱，并没那么好改。



<font color=red style="font-size: 30px;">使用RxSwift的理由4：RxSwift可以按照符合直觉的逻辑顺序来实现一些异步操作。</font>

``` swift

func startVideoPlayChain(videoUrl: String?) {
        videoUrl
            .checkUnwrap { videos[$0] }? // 业务逻辑，怎么转换
            .checkUnwrap { $0.title }? // 业务逻辑，需要什么参数
            .checkUnwrap { print($0) } // 业务逻辑，统计
    }

```

还是之前那段代码，异常处理本来有许多的分支控制，但通过函数实现了逻辑“顺序化”。

#### 还是那个简单的需求

* 点击按钮，开始倒计时，倒数5秒
* 倒计时完毕后，提交记录到服务器
* 请求成功返回后更新文本框提示


![](http://image.runmaf.com/2020-10-14-16006088477403.jpg)

``` swift

loadButton.rx
    .tap
    .flatMap(start5SecondTimer)
    .filter{ $0 <= 0 }
    .map { _ in () }
    .flatMap(requestData).bind(to: resultLabel.rx.text)

```





