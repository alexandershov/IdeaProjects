# build it with: `make build-docker-fastapi`
# run it with `make run-docker-fastapi`

# base image
FROM ubuntu:22.04

# commands run on top of the base image
RUN apt-get update -y
RUN apt-get install -y python3 python3-pip
RUN pip3 install asyncpg fastapi pydantic strawberry-graphql uvicorn

# container listens on tcp port 8000, this is just a documentation
# use -p host_port:container_port when running a container to publish a port
EXPOSE 8000

# add file from the current directory to /apps directory in the container
ADD fastapi_app.py /apps/

# container command
ENTRYPOINT ["python3", "/apps/fastapi_app.py"]