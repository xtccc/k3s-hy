## 将hy部署在k3s上

### 需要手动修改的文件

1. Dockerfile 中的代理
2. config1/hy2.yaml中的 hy客户端配置文件
3. config2/hy2.yaml中的 hy客户端配置文件
4. config1/kustomize.yaml中的 namePrefix 可自行修改，也可以不修改


### 不安装到 hy 命名空间下
如果不将svc,deploy装到hy 命名空间下，那么需要将hysteria-kustomize/base/kustomize.yaml中的 
namespace: hy 去除

```shell
# 下面这几行这是为了将curl打入镜像
docker pull tobyxdd/hysteria
docker build -t hy .
docker save hy:latest -o hy.tar
sudo k3s ctr images import hy.tar
sudo k3s ctr images ls | grep hy
rm  hy.tar || echo ""


##下面是开始部署了
cd hysteria-kustomize
#echo "显示配置文件"
#kustomize build overlays/config1
#kustomize build overlays/config2


# 替换配置文件中的外部ip为你的实际的机器ip，到时候使用代理就是 下面的这个机器ip:1080/ip:1081
sed -i "s/eip/192.168.x.x/" service.yaml


kubectl apply -f service.yaml
kubectl apply -k overlays/config1
kubectl apply -k overlays/config2

kubectl rollout restart deployment -l app=proxy-upstream -n hy
kubectl rollout status deployment -l app=proxy-upstream -n hy




kubectl get svc -n hy
#查看 svc的endpoint
#kubectl get endpoints hysteria-service   -o yaml -n hy
kubectl get deploy -n hy
kubectl get pod -n hy
```



### k3s安装

- `--disable=servicelb`: 禁用默认的 ServiceLB 负载均衡器。
- `--disable=traefik`: 禁用 Traefik Ingress 控制器。
- 没有ipv6需求的可以不带最后的三个参数

```bash
curl -sfL https://get.k3s.io | sh -s - \
--disable=servicelb \
--disable=traefik \
--cluster-cidr=10.42.0.0/16,2001:cafe:42::/56 \
--service-cidr=10.43.0.0/16,2001:cafe:43::/112 \
--flannel-ipv6-masq
```

```
systemctl status k3s
```

```
sudo pacman -S kubectl
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
kubectl cluster-info
kubectl get nodes
```