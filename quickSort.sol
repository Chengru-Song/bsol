// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.4;
pragma experimental ABIEncoderV2;

library defs {
    struct buyer {
        address payable addr;
        uint value;
        uint volumn;
    }
        
    struct seller {
        address payable addr;
        uint price;
        uint volumn;
    }
    
    struct buyBlindBid {
        bytes32 bid;
        uint deposit;
        uint volumn;
    }
        
    struct sellBlindBid {
        bytes32 bid;
        uint volumn;
    }
}


contract QuickSortSeller {

    function asceSort(defs.seller[] memory arr) external returns(defs.seller[] memory) {
        defs.seller[] memory data = arr;
        asceQuickSort(data, int(0), int(data.length - 1));
        return data;
    }
    
    // function sort(seller[] memory arr) external {
    //     seller[] memory data = arr;
    //     quickSort(data, int(0), int(data.length - 1));
    // }
    
    function asceQuickSort(defs.seller[] memory arr, int left, int right) internal {
        int i = left;
        int j = right;
        if(i==j) return;
        defs.seller memory pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)].price < pivot.price) i++;
            while (pivot.price < arr[uint(j)].price) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            asceQuickSort(arr, left, j);
        if (i < right)
            asceQuickSort(arr, i, right);
    }
}

contract QuickSortBuyer {
    function descSort(defs.buyer[] memory data) public returns(defs.buyer[] memory) {
        descQuickSort(data, int(0), int(data.length - 1));
        return data;
    }
    
    function descQuickSort(defs.buyer[] memory arr, int left, int right) internal {
        int i = left;
        int j = right;
        if(i==j) return;
        defs.buyer memory pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)].value > pivot.value) i++;
            while (pivot.value > arr[uint(j)].value) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            descQuickSort(arr, left, j);
        if (i < right)
            descQuickSort(arr, i, right);
    }
}

contract ClearingPrice {
    function findClearingPrice(defs.buyer[] memory b, defs.seller[] memory s) 
    public pure returns (uint price, uint bp, uint sp) {
        if (b.length == 0 || s.length == 0) {
            return (0, 0, 0);
        }
        // uint bp = 0;
        // uint sp = 0;
        // uint bSum = 0;
        // uint sSum = 0;
        // uint clearingPrice = 0;

        // while(bp < b.length && sp < s.length) {
        //     if(b[bp].value > s[sp].price) {
        //         bSum += b[bp].volumn;
        //         sSum += s[sp].volumn;
        //         bp++;
        //         sp++;
        //     } else {
        //         bp--;
        //         sp--;
        //         clearingPrice = (b[bp].value + s[sp].price) / 2;
        //         break;
        //     }
        // }
        uint i = 0;
        uint j = 0;
        uint feasible_i = 0;
        uint feasible_j = 0;
        uint buyerSum = 0;
        uint sellerSum = 0;
        while(b[i].value >= s[j].price && i < b.length && j < s.length) {
            if(buyerSum == sellerSum) {
                buyerSum += b[i].volumn;
                sellerSum += s[j].volumn;
            } else if (buyerSum > sellerSum) {
                sellerSum += s[j].volumn;
            } else {
                buyerSum += b[i].volumn;
            }
            feasible_i = i;
            feasible_j = j;
            if(buyerSum > sellerSum) {
                j++;
            } else if (buyerSum < sellerSum) {
                i++;
            } else {
                i++;
                j++;
            }
        }

        
        uint clearingPrice = (b[feasible_i].value + s[feasible_j].price) / 2;
        return (clearingPrice, feasible_i, feasible_j);
    }
}