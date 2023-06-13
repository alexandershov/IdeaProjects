# build an image from ./Dockerfile
build-docker-fastapi:
	docker build -t ubuntu-fastapi-app .

# run ubuntu-fastapi-app image with the given environment
# and forwarding host:7001 to container:8000
run-docker-fast-api:
	docker run -e DB_USER=aershov -e DB_HOST=host.docker.internal \
	-p 7001:8000 ubuntu-fastapi-app
