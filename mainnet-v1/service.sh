#!/usr/bin/env sh

. $HOME/launch/mainnet-v1/variables.sh

NODE_DIR=${NODE_DIR:-$HOME/node}
BIN_DIR=$(go env GOPATH)/bin
USER=$(whoami)


VALIDATOR_ADDRESS='${VALIDATOR_ADDRESS}'

cat > metadata <<EOF
VALIDATOR_ADDRESS=
EOF

cat > bor.service <<EOF
[Unit]
  Description=bor
  StartLimitIntervalSec=500
  StartLimitBurst=5

[Service]
  Restart=on-failure
  RestartSec=5s
  WorkingDirectory=$NODE_DIR
  EnvironmentFile=/etc/matic/metadata
  ExecStartPre=/bin/chmod +x $NODE_DIR/bor/start.sh
  ExecStart=/bin/bash $NODE_DIR/bor/start.sh $VALIDATOR_ADDRESS
  Type=simple
  User=$USER
  KillSignal=SIGINT
  TimeoutStopSec=120

[Install]
  WantedBy=multi-user.target
EOF

cat > heimdalld.service <<EOF
[Unit]
  Description=heimdalld
  StartLimitIntervalSec=500
  StartLimitBurst=5

[Service]
  Restart=on-failure
  RestartSec=5s
  WorkingDirectory=$NODE_DIR
  ExecStart=$BIN_DIR/heimdalld start --home $MOUNT_DATA_DIR/.heimdalld --with-heimdall-config $MOUNT_DATA_DIR/.heimdalld/config/heimdall-config.json
  Type=simple
  User=$USER

[Install]
  WantedBy=multi-user.target
EOF

cat > heimdalld-rest-server.service <<EOF
[Unit]
  Description=heimdalld-rest-server
  StartLimitIntervalSec=500
  StartLimitBurst=5

[Service]
  Restart=on-failure
  RestartSec=5s
  WorkingDirectory=$NODE_DIR
  ExecStart=$BIN_DIR/heimdalld rest-server --home $MOUNT_DATA_DIR/.heimdalld --with-heimdall-config $MOUNT_DATA_DIR/.heimdalld/config/heimdall-config.json
  Type=simple
  User=$USER

[Install]
  WantedBy=multi-user.target
EOF

cat > heimdalld-bridge.service <<EOF
[Unit]
  Description=heimdalld-bridge

[Service]
  WorkingDirectory=$NODE_DIR
  ExecStart=$BIN_DIR/bridge start --all
  Type=simple
  User=$USER

[Install]
  WantedBy=multi-user.target
EOF
