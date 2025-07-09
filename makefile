export LATEST_VERSION=1.4.1

docker-build:
	docker build -f golang.dockerfile \
 			-t joseph50804/golang-basic:${LATEST_VERSION}  \
 			-t joseph50804/golang-basic:latest \
 			--build-arg="GOLANG_VERSION=1.23.7-alpine" .
docker-push:
	docker push joseph50804/golang-basic:${LATEST_VERSION}
	docker push joseph50804/golang-basic:latest
