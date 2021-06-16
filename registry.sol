// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

contract BenchmarkRegistry {
    constructor() {}
    
    uint owner;
    function BenchmarkSetRecord() public {
        owner = 1;
    }

    function BenckmarkSetResolver() public {
        owner = 2;
        owner = 3;
        owner = 4;
    }

    mapping (uint => uint) test;
    function BenchmarkSetOwner() public {
        test[1] = 2;
        test[2] = 1;
    }

    function BenchmarkSetSubnodeRecord() public {
        test[3] = 4;
    }
    
    function BenchmarkSetSubnodeOwner() public {
        test[5] = 6;
        test[9] = 1;
        test[10] = 2;
    }

    function BenchmarkSetTTL() public {
        uint ttl = 1;
    }
}
