FROM logstash:7.14.0

ADD --chown=logstash:logstash https://jdbc.postgresql.org/download/postgresql-42.2.23.jar /usr/share/logstash/bin/

RUN chmod +x /usr/share/logstash/bin/postgresql-42.2.23.jar
