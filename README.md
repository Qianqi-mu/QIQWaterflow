# QIQWaterflow #

QIQWaterflow是一个类似*UITableView*原理实现的瀑布流，使用方法也跟*UITableView*类似。下面会详细描述QIQWaterflow的实现原理和使用。

####声明
QIQWaterflow是本人借鉴网上某位大神的思路实现的，并不属于原创。这个Demo，希望能够让更多的人了解*UITableView*的底层实现原理。

## 实现原理
- 新建两个类
	- 继承自*UIScrollView*的子类，`QIQWaterflowView`---瀑布流的显示控件，用来显示所有的瀑布流数据。
	- 继承自*UIView*的子类， `QIQWaterflowViewCell`---用来显示瀑布流中的一个单元。
	- `QIQWaterflowView`和`QIQWaterflowViewCell`的关系类似于*UITableView*和*UITableViewCell*的关系。

- `QIQWaterflowView`的接口设计
	- 模仿*UITableView*设计一套数据源和代理方法:
		
			<QIQWaterflowViewDataSource>
			/* 一共有多少个cell */
			- (NSUInteger)numberOfCellsInWaterflowView:(QIQWaterflowView *)waterflowView;

			/* index位置对应的cell */
			- (QIQWaterflowViewCell *)waterflowView:(QIQWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

			/* 瀑布流一共有多少列 */
			- (NSUInteger)numberOfColumnsInWaterflowView:(QIQWaterflowView *)waterflowView;
		
		
			<QIQWaterflowViewDelegate>
			/* index位置对应cell的高度 */
			- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;

			/* index位置对应cell的点击事件 */
			- (void)waterflowView:(QIQWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;
		
		
- `QIQWaterflowView`的实现
	- 创建三个容器，分别用来缓存所有数据对应cell的frame、正在屏幕上展示的cell、不在屏幕上的cell
			
			/* 所有数据对应cell的frame */
			@property (nonatomic, strong) NSMutableArray *cellFrames;

			/* 正在屏幕上展示的cell（cell对应的index作为字典的key） */
			@property (nonatomic, strong) NSMutableDictionary *displayingCells;

			/* 不在屏幕上的cell（供数据源使用） */
			@property (nonatomic, strong) NSMutableSet *reusableCells;
			
	- `reloadData`，用于刷新瀑布流上的数据
	
			1.清除原有缓存数据，包括cellFrames、displayingCells、reusableCells里的数据
			2.计算所有数据对应cell的frame，并缓存至cellFrames中
			3.计算瀑布流的contentSize
	
	
	- `layoutSubviews`，监听瀑布流中每个cell的是否在屏幕上
	
			1.监测scrollView滑动的时候，要遍历所有数据对应的frame，判断哪些数据对应的cell要展示在屏幕上
			2.如果某个数据对应的cell要展示在屏幕上，那么先根据这个数据对应的index从displayingCells里面取，取到了说明这个数据对应的cell正在屏幕上；若没取到，则向数据源索取对应位置的cell，将索取到的cell放入displayingCells中并展示在屏幕上
			3.如果某个数据对应的cell不需要展示在屏幕上了，那么就将这个数据对应的cell放入reusableCells中，并将其分别从屏幕上和displayingCells中移除
			
	- `dequeueReusableCellWithIdentifier`: 提供给数据源使用缓存池reusableCells的接口
	
			1.当瀑布流向数据源索取某数据对应位置的cell时，数据源会优先调用此方法，从reusableCells中获取可用的cell。
			2.如果取到了，则将此cell从reusableCells中移除，并返回给瀑布流；如果没去到，则由数据源新建一个cell，并返回给瀑布流。
			
##使用方法
`QIQWaterflowView`的使用方法与*UITableView*的使用类似，如下：
	
		//首先，在一个普通视图控制器中创建瀑布流视图控件，并设置好数据源和代理
		- (void)viewDidLoad {
    		[super viewDidLoad];
    
    		QIQWaterflowView *waterflowView = [[QIQWaterflowView alloc] init];
    		waterflowView.waterflowDelegate = self;
    		waterflowView.waterflowDataSource = self;
    		waterflowView.frame = self.view.bounds;
    		[self.view addSubview:waterflowView];
    
		}

		//然后，实现瀑布流的数据源方法和代理方法即可
		#pragma mark - Waterflow DataSource
		- (NSUInteger)numberOfColumnsInWaterflowView:(QIQWaterflowView *)waterflowView {
        	return 3;
    	}

		- (NSUInteger)numberOfCellsInWaterflowView:(QIQWaterflowView *)waterflowView {
    		return 200;
		}

		/* 也可以创建继承自QIQWaterflowViewCell子类的自定义cell */
		- (QIQWaterflowViewCell *)waterflowView:(QIQWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index {
    		static NSString *ID = @"cell";
    		QIQWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    		if (!cell) {
        		cell = [[QIQWaterflowViewCell alloc] initWithIdentifier:ID];
    		}
    		/* TODO... */
        	return cell;
		}

		- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index {
    		switch (index % 3) {
        		case 0: return 70;
        		case 1: return 100;
        		case 2: return 190;
        		default: return 110;
    		}
		}
			
