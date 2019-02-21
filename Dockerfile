FROM node:8

LABEL version="1.0.0"
LABEL repository="http://github.com/stephenwf/module-release-action"
LABEL homepage="http://github.com/stephenwf/module-release-action"
LABEL maintainer="Stephen Fraser <stephen.fraser@digirati.com>"

LABEL com.github.actions.name="Monorepo module release action"
LABEL com.github.actions.description="Deploys prerelease and release versions in lerna monorepos."
LABEL com.github.actions.icon="package"
LABEL com.github.actions.color="red"

RUN npm install -g @fesk/module-release

RUN wget "http://stedolan.github.io/jq/download/linux64/jq" -O /bin/jq && chmod 755 jq

COPY "entrypoint.sh" "/entrypoint.sh"
ENTRYPOINT ["/entrypoint.sh"]

