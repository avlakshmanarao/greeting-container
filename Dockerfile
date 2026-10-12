FROM python:3.12@sha256:63828510c8b5ccce3bf0d6fabd6f3d17d4effa1ffe690f80a67c8e2d394e03ee

#Addde following environment variables 
# PYTHONDONTWRITEBYTECODE - prevents Python from writing bytecode (pyc) temporary files and 
# PYTHONUNBUFFERED - makes Python output appear promptly in logs without any dealy
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 

# Removed unnecessary packages as
#    build-essential package include compilers and build tools which increases image size, 
#    gcc is c compiler also not needed;
#    curl is not essential tool required in production container
#    vim interactive editor is also not needed in production container

# create custom user/group appuser:appgroup  10001:10001
RUN groupadd --gid 10001 appgroup \
    && useradd --uid 10001 --gid appgroup --no-create-home appuser

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#run container as non-root user to improve security
COPY --chown=appuser:appgroup app/ .

USER appuser:appgroup

EXPOSE 8080
# blow commonds also sends gunicorn logs to container's stdout/stderr streams
# timeout/graceful-timeout parameters enalbes  to terminate workers that fail to respond within configured timeout or allow workers time to finish requests during graceful shutdown. So that it prevents request from hanging indefinitely
CMD ["gunicorn", "--bind=0.0.0.0:8080", "--workers=2", "--access-logfile=-", "--error-logfile=-", "--timeout=30", "--graceful-timeout=30", "app:app"]