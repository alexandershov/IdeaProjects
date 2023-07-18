FROM ubuntu:22.04

RUN apt-get update -y
RUN apt-get install -y python3 python3-pip
RUN pip3 install fastapi uvicorn supervisor
RUN mkdir /var/log/supervisord

# app.py is running on :8889
EXPOSE 8889
# supervisord interface is running on :9001
EXPOSE 9001


ADD app.py /apps/app.py
ADD supervisord.conf /etc

CMD ["supervisord"]