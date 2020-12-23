FROM ubuntu:latest

# Installing needed soft
RUN apt-get update -y && \
    apt-get -y install curl unzip vim

# Adding scripts and rsync conf
COPY . /home/collector/
RUN chmod +x /home/collector/run.sh
RUN chmod +x /home/collector/install_rclone.sh
RUN /home/collector/install_rclone.sh

CMD ["sh", "-c", "/home/collector/run.sh"]
