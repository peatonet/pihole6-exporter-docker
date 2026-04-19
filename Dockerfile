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

# Patch: validate auth, store key, re-auth once, raise on unrecovered errors
RUN sed -i "s|        return reply\['session'\]\['sid'\]|        sess = reply.get('session') or {}\n        if not sess.get('valid') or not sess.get('sid'):\n            raise RuntimeError('Pi-hole auth failed: ' + str(sess.get('message') or reply))\n        return sess['sid']|" pihole6_exporter && \
    sed -i 's/            self\.sid = self\.get_sid(key)/            self.sid = self.get_sid(key)\n            self.key = key/' pihole6_exporter && \
    sed -i 's/        return req\.json()/        reply = req.json()\n        if self.using_auth and isinstance(reply, dict) and reply.get("error", {}).get("key") == "unauthorized":\n            logging.info("session expired, re-authenticating...")\n            self.sid = self.get_sid(self.key)\n            headers["sid"] = self.sid\n            req = requests.get(url, verify = False, headers = headers)\n            reply = req.json()\n        if isinstance(reply, dict) and "error" in reply:\n            raise RuntimeError("Pi-hole API error on " + api_path + ": " + str(reply["error"]))\n        return reply/' pihole6_exporter

# Patch: fix timezone bug — datetime.now().strftime("%s") treats local time as UTC
RUN sed -i 's/now = datetime\.now()\.strftime("%s")/now = str(int(time.time()))/' pihole6_exporter

# Patch: read host/key from env vars directly — avoids shell-expansion mangling
# when the API key contains special chars ($, `, ", \, !, space).
RUN sed -i 's|    args = parser\.parse_args()|    args = parser.parse_args()\n    if os.getenv("PIHOLE_HOST"):\n        args.host = os.getenv("PIHOLE_HOST")\n    if os.getenv("PIHOLE_API_KEY"):\n        args.key = os.getenv("PIHOLE_API_KEY")|' pihole6_exporter

# Python deps (requirements.txt exists in that repo)
RUN pip install --no-cache-dir prometheus_client requests

# If the main file is an executable script (no .py), make sure it’s executable
RUN chmod +x pihole6_exporter

# Expose Prometheus port
EXPOSE 9666

# Pure exec form — no shell, no expansion. Env vars read directly by Python.
ENTRYPOINT ["python3", "-u", "/opt/pihole6_exporter/pihole6_exporter"]
CMD []