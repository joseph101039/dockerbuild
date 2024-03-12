docker-build:
	docker build -f golang.dockerfile -t joseph50804/golang-basic:1.1.0 .
docker-push:
	docker push joseph50804/golang-basic:1.1.0