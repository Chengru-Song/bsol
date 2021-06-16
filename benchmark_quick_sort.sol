// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./quickSort.sol";

contract BenchmarkQuicksort {
    constructor() {}

    // function BenchmarkSort() public {
    //     defs.seller[] memory s = new defs.seller[](6);
    //     for(uint i=0; i<6; i++) {
    //         s[i] = defs.seller({
    //             addr: msg.sender,
    //             price: (6-i) * 10,
    //             volumn: 10
    //         });
    //     }
    //     QuickSortSeller sellerSort = new QuickSortSeller();
    //     s = sellerSort.asceSort(s);
    // }

    // function BenchmarkPrice() public {
    //     defs.buyer[] memory b = new defs.buyer[](5);
    //     b[0] = defs.buyer({addr: msg.sender, value: 10, volumn: 20});
    //     b[1] = defs.buyer({addr: msg.sender, value: 9, volumn: 10});
    //     b[2] = defs.buyer({addr: msg.sender, value: 8, volumn: 20});
    //     b[3] = defs.buyer({addr: msg.sender, value: 7, volumn: 30});
    //     b[4] = defs.buyer({addr: msg.sender, value: 6, volumn: 40});

    //     defs.seller[] memory s = new defs.seller[](4);
    //     s[0] = defs.seller({addr: msg.sender, price: 6, volumn: 30});
    //     s[1] = defs.seller({addr: msg.sender, price: 7, volumn: 10});
    //     s[2] = defs.seller({addr: msg.sender, price: 8, volumn: 30});
    //     s[3] = defs.seller({addr: msg.sender, price: 10, volumn: 100});

    //     ClearingPrice cp = new ClearingPrice();
    //     uint price; uint bp; uint sp;
    //     (price, bp, sp) = cp.findClearingPrice(b, s);
    // }
    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length;
    }

    function BenchmarkPriceTen() public {
        uint nums = 1000;
        defs.buyer[] memory b = new defs.buyer[](nums);
        
        for(uint i=0; i<nums; i++) {
            // uint256 valueRandom = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % length;
            // uint256 volumnRandom = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % length;
            b[i] = defs.buyer({addr: msg.sender, value: rand(100), volumn: rand(100)});
        }
        
        defs.seller[] memory s = new defs.seller[](nums);
        for(uint i=0; i<nums; i++) {
            // uint256 valueRandom = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % length;
            // uint256 volumnRandom = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % length;
            s[i] = defs.seller({addr: msg.sender, price: rand(100), volumn: rand(100)});
        }

        ClearingPrice cp = new ClearingPrice();
        uint price; uint bp; uint sp;
        (price, bp, sp) = cp.findClearingPrice(b, s);
    }
}
