#!/bin/sh

rain meta build             -i <(rain meta solc artifact -c abi -i out/Flow.sol/Flow.json) -m solidity-abi-v2 -t json -e deflate -l en > meta/Flow.meta