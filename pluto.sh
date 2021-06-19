#!/bin/sh

# sets project (includes dependencies spec) and current working directory
julia --optimize=0 --project="." -e "import Pluto; Pluto.run()"
