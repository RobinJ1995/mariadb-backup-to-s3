FROM debian:testing

RUN apt-get update \
  && apt-get install -y mariadb-client wget unzip zstd

RUN wget -O "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN aws --version

WORKDIR /script
COPY main.sh main.sh

CMD ["bash", "main.sh"]
