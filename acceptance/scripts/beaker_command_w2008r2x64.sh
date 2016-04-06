#!/bin/bash

beaker \
  --pre-suite ../setup/pe_install.rb \
  --config ../config/windows-2008r2-x86_64.cfg \
  --debug \
  --tests ../tests \
  --keyfile ~/.ssh/id_rsa-acceptance \
  --preserve-hosts onfail \
  --timeout 6000
