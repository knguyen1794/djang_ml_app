FROM tiangolo/uwsgi-nginx:latest

# Indicate where uwsgi.ini lives
ENV UWSGI_INI uwsgi.ini

WORKDIR /app

COPY requirements.txt /app
RUN python3 -m pip install -r requirements.txt

ADD . /app

# Set environment variables from .env during collect static
# so that the app uses the production location for static files
RUN export $(grep -v '^#' .env | xargs) && python3 manage.py makemigrations -noinput \ 
    && python3 manage.py migrate --noinput && python3 manage.py collectstatic --noinput
RUN rm .env

ARG USERNAME=first_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME


# If the app is being deployed to Azure App Service
# then we can enable SSH with the below
# ENV SSH_PASSWD "root:Docker!"
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends dialog \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends openssh-server \
#     && echo "$SSH_PASSWD" | chpasswd 
# COPY sshd_config /etc/ssh/
# # COPY init.sh /usr/local/bin/

EXPOSE 8000 2222
