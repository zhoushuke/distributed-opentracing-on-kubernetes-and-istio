# Kubernetes+Istio+GRPC-GATEWAY+RESTful+OPENTRACING

这个项目基于这个[项目]([garystafford/k8s-istio-observe-backend](https://github.com/garystafford/k8s-istio-observe-backend))改造而来，主要用于测试在Kubernetes+Istio微服务架构下，使用jaeger+kiali来可视化GRPC gateway与restful两种常用的服务间调用方式.

**这里主要进行的改变是grpc gateway服务集成到了服务内部, 在原项目中, gateway是被部署在单独的容器中**



![](https://raw.githubusercontent.com/zhoushuke/BlogPhoto/master/githuboss/kiaki_v2.png)



### 架构

![](https://raw.githubusercontent.com/zhoushuke/BlogPhoto/master/githuboss/architecture_v2.png)

通过jaeger在请求header中注入trace达到全链路追踪目的:

```yaml
var (
        otHeaders = []string{
                "x-request-id",
                "x-b3-traceid",
                "x-b3-spanid",
                "x-b3-parentspanid",
                "x-b3-sampled",
                "x-b3-flags",
                "x-ot-span-context"}
)
```



### 响应信息

服务间的代码没多大区别, response信息如下, 通过在response中指明所属service来反映服务提供者

```json
{
  "id": "844ea9c7-b340-4956-9c8b-f28ae42d0f4a",
  "service": "Service-A",
  "message": "Hello, from Service-A!",
  "created": "2019-03-17T16:10:16.4982543Z"
}
```



### 部署

#### 前提

需要一个kubernetes集群,部署了istio及开启了jaeger和kiali, 这部分不在这里展开. 可参考[这里](https://izsk.me/2020/01/03/Istio-Install-Upon-Kubernetes/)

#### 编译镜像

```bash
cd services
bash part1_build_srv_images.sh
```

#### 镜像发布

```bash
cd resources
bash part2_deploy_resources.sh
```



### 请求

使用如下命令请求一条完整的路径

```bash
curl -H'Content-Type: application/json' 'your-service-a-svc-clusterIP:8088/api/v1/greeting'
```

其中**your-service-a-clusterIP**是真实环境下的集群地址

请求返回的信息如下:

```json
{
  "greeting": [
    {
        "id": "9f12e095-989f-49aa-80f7-05f27a1ae2ef",
        "service": "Service-D",
        "message": "Shalom, from Service-D!",
        "created": "2019-03-17T16:10:16.197706983Z"
    },
    {
        "id": "a2ed6cac-88bc-42b5-9d94-7b64a655ead9",
        "service": "Service-G",
        "message": "Ahlan, from Service-G!",
        "created": "2019-03-17T16:10:16.229348021Z"
    },
    {
        "id": "d5384ee3-1d43-460a-abc8-142e5d5f5b8e",
        "service": "Service-H",
        "message": "Ciao, from Service-H!",
        "created": "2019-03-17T16:10:16.293059651Z"
    },
    {
        "id": "953d654d-5c32-4d5d-9ce1-e158dee3701b",
        "service": "Service-E",
        "message": "Bonjour, de Service-E!",
        "created": "2019-03-17T16:10:16.414109276Z"
    },
    {
        "id": "98a73e02-9c4a-443a-a4c9-1f0216d5c099",
        "service": "Service-B",
        "message": "Namaste, from Service-B!",
        "created": "2019-03-17T16:10:16.415805403Z"
    },
    {
        "id": "d5cd62d4-fe79-4b6b-81a9-80d59f3d42c3",
        "service": "Service-C",
        "message": "Konnichiwa, from Service-C!",
        "created": "2019-03-17T16:10:16.420415356Z"
    },
    {
        "id": "844ea9c7-b340-4956-9c8b-f28ae42d0f4a",
        "service": "Service-A",
        "message": "Hello, from Service-A!",
        "created": "2019-03-17T16:10:16.4982543Z"
    }
  ]
}
```



### 效果

jaeger上展示的效果如下:

![](https://raw.githubusercontent.com/zhoushuke/BlogPhoto/master/githuboss/jaeger.png)

kiali上展示的效果如下:

![](https://raw.githubusercontent.com/zhoushuke/BlogPhoto/master/githuboss/kiali.png)



### Istio流量管理

在目录istio-traffic-managerment-yaml下有几个关于istio对流量管理的实践, 具体大家可参考[这里](https://izsk.me/2020/02/29/Istio-VirtualService-DestinationRule/)

