# Dockerfile
FROM python:3.9-alpine

# Install git + certs
RUN apk update && apk add --no-cache git ca-certificates

# Workdir
WORKDIR /opt/pihole6_exporter

# Get the code
RUN git clone https://github.com/bazmonk/pihole6_exporter.git .

# Patch script to use PIHOLE_SCHEME / PIHOLE_PORT
RUN sed -i '1,/^import requests/ s/^import requests/import requests\nimport os/' pihole6_exporter && \
    sed -i 's#"https://" + self.host + ":443/api/auth"#"{}://".format(os.getenv("PIHOLE_SCHEME","http")) + self.host + ":" + os.getenv("PIHOLE_PORT","80" if os.getenv("PIHOLE_SCHEME","http")=="http" else "443") + "/api/auth"#' pihole6_exporter && \
    sed -i 's#"https://" + self.host + ":443/api/" + api_path#"{}://".format(os.getenv("PIHOLE_SCHEME","http")) + self.host + ":" + os.getenv("PIHOLE_PORT","80" if os.getenv("PIHOLE_SCHEME","http")=="http" else "443") + "/api/" + api_path#' pihole6_exporter

# Python deps (requirements.txt exists in that repo)
RUN pip install --no-cache-dir prometheus_client requests

# If the main file is an executable script (no .py), make sure it’s executable
RUN chmod +x pihole6_exporter

# Expose Prometheus port
EXPOSE 9666

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["python3 -u pihole6_exporter -H ${PIHOLE_HOST} -p 9666 -k ${PIHOLE_API_KEY}"]