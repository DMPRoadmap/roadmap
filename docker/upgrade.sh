#!/bin/bash


bin/rails db:migrate

# Place upgrade tasks here. They will be executed as part of the Docker build process (after bundler runs)
#   For example: bin/rails v4:upgrade_4_0_8
bin/rails v4:upgrade_4_0_8
