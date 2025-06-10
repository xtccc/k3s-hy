FROM tobyxdd/hysteria
ENV https_proxy=http://192.168.x.x:8080
RUN apk add curl
ENTRYPOINT ["hysteria"]
