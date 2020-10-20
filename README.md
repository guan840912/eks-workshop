# EKS Workshop
> 創建 aws eks 有很多方法 , 可以使用 [awscdk](https://docs.aws.amazon.com/cdk/api/latest/docs/aws-eks-readme.html) , [terraform](https://github.com/terraform-aws-modules/terraform-aws-eks) ,[eksctl](https://eksctl.io/introduction/) 等等..., 今天使用對於創建 AWS EKS 叢集經驗跟知識比較不需要這麼高的方式來創建 AWS EKS 叢集 [eksctl](https://eksctl.io/introduction/) 。

## Preinstall eksctl and awscli
- [eksctl info](https://eksctl.io/introduction/#installation)
- [awscli info](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [kubectl for aws](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

#### Linux
```bash=
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```
#### Mac OS
##### use Homebrew
```bash=
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```
#### Windows
[download_link](https://github.com/weaveworks/eksctl/releases/download/0.30.0/eksctl_Windows_amd64.zip)



# 若以上都不想做點我吧 !!!     [![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/guan840912/eks-workshop)


![](https://i.imgur.com/MhjchrM.png)
### 如果您不是使用 Admin User , 請確定至少有以下權限 [AWS 相關最低權限](https://eksctl.io/usage/minimum-iam-policies/)
```bash=
export AWS_ACCESS_KEY_ID=AAAAAAAAAAAAAAAAA
export AWS_SECRET_ACCESS_KEY=AAAAAAAAAAAAAAAAAVVVVVVVVVVVVVVV
export AWS_DEFAULT_REGION=ap-northeast-1

# 先確認目前使用的身份。
aws sts get-caller-identity

eksctl create cluster \
   --name eks-2020-{NAME} \
   --managed \
   --node-type t3.medium
[ℹ]  eksctl version 0.28.1
[ℹ]  using region ap-northeast-1
[ℹ]  setting availability zones to [ap-northeast-1a ap-northeast-1d ap-northeast-1c]
[ℹ]  subnets for ap-northeast-1a - public:192.168.0.0/19 private:192.168.96.0/19
[ℹ]  subnets for ap-northeast-1d - public:192.168.32.0/19 private:192.168.128.0/19
[ℹ]  subnets for ap-northeast-1c - public:192.168.64.0/19 private:192.168.160.0/19
[ℹ]  using Kubernetes version 1.17
[ℹ]  creating EKS cluster "eks-2020-{name}" in "ap-northeast-1" region with managed nodes
[ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
[ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-northeast-1 --cluster=eks-2020-{name}'
[ℹ]  CloudWatch logging will not be enabled for cluster "eks-2020-{name}" in "ap-northeast-1"
[ℹ]  you can enable it with 'eksctl utils update-cluster-logging --region=ap-northeast-1 --cluster=eks-2020-{name}'
# 創建叢集須等待 20 分鐘左右
# get nodes ...
kubectl get nodes 
```

### 但是這個過程中 eksctl 幫你做了什麼呢？！
> 創建了 vpc , nat , eks cluster ,node workgroup (ec2) ...

![](https://i.imgur.com/BJOIbZf.png)
會創建兩個 cloudformation stack
- eks cluster 加網路等等...
![](https://i.imgur.com/aJQuMib.png)
- eks worker nodegroup...
![](https://i.imgur.com/6NN84q4.png)
創建完成後，因為為 managed nodegroup , 所以可以在 [eks console](https://ap-northeast-1.console.aws.amazon.com/eks/home?region=ap-northeast-1#/clusters)看到 compute 
nodegroup 們。
![](https://i.imgur.com/vsdFbbX.png)

可以說 eksctl 真的很方便呢 但是如果 `create cluster` 時，還沒裝 `aws` and `kubectl`怎麼辦呢？！
> 可以這麼做 
```bash=
# 安裝完 aws cli 以及 kubectl 後 
# 什麼?! 忘記 cluster name  
# try : eksctl get cluster --region ${region_name}
# see more aws eks cli ... https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html
aws eks update-kubeconfig --name ${Cluster_name} --region ${region_name}

kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.2", GitCommit:"f5743093fd1c663cb0cbc89748f730662345d44d", GitTreeState:"clean", BuildDate:"2020-09-16T21:51:49Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"16+", GitVersion:"v1.16.13-eks-2ba888", GitCommit:"2ba888155c7f8093a1bc06e3336333fbdb27b3da", GitTreeState:"clean", BuildDate:"2020-07-17T18:48:53Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```

## 所以 AWS EKS 是怎麼做授權的呢？！
創建Amazon EKS集群時，會在集群的RBAC配置中自動向IAM實體用戶或角色（例如創建集群的聯合用戶）授予system：masters權限。 要授予其他AWS用戶或角色與集群進行交互的能力，您必須在Kubernetes中編輯 `aws-auth` ConfigMap，而因為我們使用的是 eksctl 創建叢集不會出現在 `aws-auth` 但擁有 system:master 權限。

#### 可以看看 `aws-auth` 這個 configmaps 目前長什麼樣子
```bash=
# aws-auth 在 kube-system namespace
kubectl -n kube-system get configmaps aws-auth -o yaml 

apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::${account_id}:role/eksctl-XXXXXXX-nodegroup-XXXXXX-NodeInstanceRole-XXXXXXXXXX
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
kind: ConfigMap
...
```


### 如果有一個以上的 叢集如何切換 指令如下。
```bash=
# 查看目前 `~/.kube/config` 有多少 context
kubectl config get-contexts

# 選取指定的 context
kubectl config use-context <context-name>
```

### 將當前的 context 預設的 namespace 設定成你想要的 namespace 指令如下。
```bash=
# 將當前的 context 預設的 namespace 設定成你想要的
kubectl config set-context --current --namespace=<ns>

# 範例
kubectl create ns haha
kubectl config set-context --current --namespace=haha
```


等待更新     

.


# 移除 EKS Cluster
```bash=
eksctl delete cluster --name eks-2020-{name}
[✔]  all cluster resources were deleted
```