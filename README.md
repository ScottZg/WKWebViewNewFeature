### WKWebView强大的新特性 

iOS11对WKWebView的功能进一步完善，新增如下功能：   
1. Manager Cookies    
2. Fileter unwanted content    
3. Provide custom resources    

下面是对各个特性的简单介绍，详细可参见[源码](https://github.com/ScottZg/WKWebViewNewFeature)。
#### 1.Manager Cookies

iOS11新增了一个类来专门管理Cookies，它就是：WKHTTPCookieStore。该类可以在WebKit里面看到。主要包含了了对Cookie的操作：删除、添加、获取等。   
比如这种场景：    
一个页面默认登录，当我没有登录的时候会弹出一个框，然后输入账号，输入完成之后，会提示已经登录，再次打开该页面的时候，会先判断有没有cookie，有cookie就直接提示已经登录，没有cookie则再次弹框让用户登录。  
但是现在有个新需求：第一次安装APP，启动的时候就有个默认的账户登录，而不需要弹框输入。这就用到了cookie的添加。在APP将要加载webView之前，便通过HTTPCookie来初始化一个实例，将其塞到webView的configuration的数据存储中。这样加载WebView时就已经有cookie存在了。这样就打熬了首次默认登录的效果。关键代码如下：  

```objective-c
let cookie = HTTPCookie.init(properties: [
            .domain:"172.16.10.26",
            .path:"/src/p/index/index.html",
            .version:0,
            .expires:Date.init(timeIntervalSinceNow: 30*60*60),
            .name:"username",
            .value:"zhanggui33"
            ])
            
let cookieStore = myWKWebView.configuration.websiteDataStore.httpCookieStore
        
cookieStore.setCookie(cookie!) {
            
            self.myWKWebView.load(URLRequest.init(url: URL.init(string: "http://172.16.10.26:3333/src/p/index/index.html")!))
        }
        
```
也就是在加载网页前，将cookie注入。更多可参见这里[源代码](https://github.com/ScottZg/WKWebViewNewFeature)。

#### 2.Fileter unwanted content
另外一个新特性就是过滤你不想要的内容。比如说你在app中加载的网页中包含http请求，你可以根据以下规则将http资源加载之前转换成https加载。这个是苹果官方演示的一个规则：  

```objective-c
let jsonString = """
            [{
                "trigger":{
                    "url-filter": ".*"
                },
                "action":{
                    "type": "make-https"
                }

            }]
            """
```
这里主要用到了WKContentRuleListStore。下面就来详细对其进行介绍。
##### 创建一个Trigger字典
一个trigger的字典**必须要包含url-filter这个key**,它指定了匹配url的模式。其他的就是可选的了，例如你可以限制指定的域名，让该域名的内容不加载。例如下面的这个trigger规则，制定了用于图片和样式资源的规则trigger，不包含某写域名上的：

```objective-c
"trigger": {
        "url-filter": ".*",
        "resource-type": ["image", "style-sheet"],
        "unless-domain": ["your-content-server.com", "trusted-content-server.com"]
}
```
除了上面提到的trigger key，还有url-filter-is-case-sensitive、is-domain、unless-domain、resource-type等。具体的详细介绍可以参见[官方解释](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html#//apple_ref/doc/uid/TP40016265-CH2-SW5)。

##### 创建一个Action字典
当trigger匹配到了符合条件的资源，浏览器便会执行与trigger相关联的操作。当所有的trigger都被评估后，action便会按照顺序执行。    
Action只有两个key：type和selector。type是必须要有的，selector可选，如果type是css-display-none,那么selector也是必须要有的。其他的type中selector是可选的。   
type的类型有：block、block-cookies、css-display-none、ignore-previous-rules、make-https。更多可以参见[官方解释](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html#//apple_ref/doc/uid/TP40016265-CH2-SW5)。   
例如我想屏蔽页面中所有图片的加载：  

```objective-c
 //把所有的图片阻塞加载
        let jsonString = """
            [{
                "trigger":{
                    "url-filter": ".*",
                    "resource-type":["image"]
                },
                "action":{
                    "type":"block"
                }
            }]
            """
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "demoRuleList", encodedContentRuleList: jsonString) { (list, error) in
            guard let contentRuleList = list else { return }
            let configuration = self.filterWebView.configuration
            configuration.userContentController.add(contentRuleList)
            self.filterWebView.load(URLRequest.init(url: URL.init(string: "http://m.baidu.com")!))
        }
```     
更多词义的解释还是看[官方文档](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html#//apple_ref/doc/uid/TP40016265-CH2-SW5)，里面介绍的很详细。
#### 3.Provide custom resources
这个特性允许你提供自定义的资源，这也可以实现离线缓存。例如你把所有的图片都放到app里面，然后网页加载图片时按照特定的scheme（比如：wk-feature://cat）来加载，然后在客户端代码中使用特定的SchemeHandler来解析即可。这里主要用到了WKURLSchemeHandler和WKURLSchemeTask。     
关键代码如下：    

```
    
        let configuration = WKWebViewConfiguration()
        let schemeHandler = MyCustomSchemeHandler.init(viewController: self)
        
        configuration.setURLSchemeHandler(schemeHandler, forURLScheme: "wk-feature")
```
实现了自己的SchemeHandler，然后对特定的Scheme进行处理。

#### 总结
如果你还在使用UIWebView,那么赶快更换为WKWebView吧。毕竟苹果更倾向于WKWebView。不断地将其功能丰富。而且经过了几个版本迭代，使用WKWebView的坑也都逐渐填平。

#### 附源码
1.[WKWebViewNewFeature](https://github.com/ScottZg/WKWebViewNewFeature)
#### 参考
1. [Customized Loading in WKWebView](https://developer.apple.com/videos/play/wwdc2017/220/)
2. [Introduction to Safari Content-Blocking Rules](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/Introduction/Introduction.html)
