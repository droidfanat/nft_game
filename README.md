### Testing

Since Truffle can't handle different versions of the Solidity compiler in the same project, in order to correctly run the tests you need to use the following commands:

base pool build :
   truffle compile
   truffle compile --config truffle-0.5.16-config.js
   truffle compile --config truffle-0.6.6-config.js
   truffle test --compiler=none

base pool build :
   truffle compile --config truffle-oracle-config.js
   truffle compile --config truffle-0.5.16-config.js
   truffle test --compiler=none
