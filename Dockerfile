FROM google/cloud-sdk:slim

COPY pipe /
COPY LICENSE.txt pipe.yml README.md /

RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
