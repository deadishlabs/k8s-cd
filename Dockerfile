FROM alpine:latest

RUN apk add --no-cache --update curl git

WORKDIR /root

COPY kube-cd-github-rc.sh /root/kube-cd-github.sh
RUN chmod +x /root/kube-cd-github-rc.sh
# RUN echo "//registry.npmjs.org/:_authToken=\${NPM_TOKEN}" > /root/.npmrc

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

CMD sh /root/kube-cd-github.sh