#!/bin/sh
# ReadyStack ZITADEL entrypoint. Creating the first instance (start-from-init, start-from-setup, setup) needs
# ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD: without it ZITADEL would create the first administrator with its
# published default password. The variable is used only when the instance is first created and is ignored on
# later starts. Everything else goes to zitadel unchanged.
set -e
case "${1:-}" in
  start-from-init|start-from-setup|setup)
    if [ -z "${ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD:-}" ]; then
      echo "zitadel: set ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD to the first administrator's password (at least 8 characters with upper- and lower-case letters, a digit and a symbol); it is used only when the instance is first created" >&2
      exit 1
    fi ;;
esac
exec zitadel "$@"
