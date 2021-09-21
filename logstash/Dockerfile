FROM logstash:7.14.0

USER logstash
WORKDIR /usr/share/logstash/bin
ADD --chown=logstash:logstash https://jdbc.postgresql.org/download/postgresql-42.2.23.jar /usr/share/logstash/bin/

RUN chmod +x /usr/share/logstash/bin/postgresql-42.2.23.jar
USER 1000
