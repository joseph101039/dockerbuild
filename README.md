
編譯 image:


1. 修改 [makefile](./makefile) 中的 `export LATEST_VERSION` 的版本

然後執行編譯 image

```shell
make docker-build
```


2. 推版 dockerhub

```shell
make docker-push
```

3. 到 [dockerhub](https://hub.docker.com/r/joseph50804/golang-basic/tags) 上檢查版本是否有更新


