FROM alpine:latest
ENV PYTHONUNBUFFERED=1

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN apk --update add bash python3-dev nginx
RUN apk add openrc --no-cache
RUN apk add linux-headers
RUN apk add --no-cache gcc musl-dev
RUN pip3 install uwsgi
COPY app.py /src
COPY templates/dice_page.html /src
COPY ./nginx.conf /etc/nginx/sites-enabled/default
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
CMD service nginx start && uwsgi -s /tmp/uwsgi.sock --chmod-socket=666 --manage-script-name --mount /=app:app
