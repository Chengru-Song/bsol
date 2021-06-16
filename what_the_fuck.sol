// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract WhatTheFuck {
    struct buyer {
        int256 price;
        int256 quantity;
        int256 cost;
    }
    
    struct seller {
        int256 price;
        int256 quantity;
    }
    
    struct revenue {
        int256 value;
        int256 quantity;
    }
    
    buyer[] public buyers;
    seller public s;
    revenue[] public revenues;
    
    constructor(int256 sellerPrice, int256 sellerAmount, buyer[] memory b) {
        s.price = sellerPrice;
        s.quantity = sellerAmount;
        for(uint i=0; i<b.length; i++) {
            buyers.push(buyer({
                price: b[i].price,
                quantity: b[i].quantity,
                cost: b[i].cost
            }));
        }
    }
    
    function getBuyerLength() public view returns(uint) {
        return buyers.length;
    }
    
    function getSeller() public view returns(int256, int256) {
        return (s.price, s.quantity);
    }
    
    function getRevenueLength() public view returns(uint) {
        return revenues.length;
    }
    
    function calculateWithCost() public returns(int256){
        for(uint i=0; i<buyers.length; i++) {
            int256 total = buyers[i].quantity * (buyers[i].price - buyers[i].cost);

            revenues.push(revenue({
                value: total,
                quantity: buyers[i].quantity
            }));
        }
        revenue[] memory r = revenues;
        quickSort(r, int(0), int(revenues.length - 1));
        
        return getProfit(r);
    }

    function calculateWithoutCost() public returns(int256){
        for(uint i=0; i<buyers.length; i++) {
            int256 total = buyers[i].quantity * buyers[i].price;
            revenues.push(revenue({
                value: total,
                quantity: buyers[i].quantity
            }));
        }
        
        revenue[] memory r = revenues;
        quickSort(r, int(0), int(revenues.length - 1));
        
        return getProfit(r);
    }
    
    function partition(revenue[] memory r, int low, int high) private pure returns(int){
        revenue memory pivot = r[uint(high)];
        
        int i = low - 1;
        for(int j=low; j<high; j++) {
            if(r[uint(j)].value > pivot.value) {
                i += 1;
                (r[uint(i)], r[uint(j)]) = (r[uint(j)], r[uint(i)]);
            }
        }
        (r[uint(i+1)], r[uint(high)]) = (r[uint(high)], r[uint(i+1)]);
        return i+1;
    }
    
    function quickSort(revenue[] memory r, int low, int high) private {
        if(low < high) {
            int pi = partition(r, low, high);
            quickSort(r, low, pi-1);
            quickSort(r, pi+1, high);
        }
    }
    
    function getProfit(revenue[] memory r) private view returns(int256) {
        int256 sumAmount = 0;
        int256 totalValue = 0;
        uint i;
        for(i=0; i<r.length; i++) {
            if(s.quantity >= sumAmount + r[i].quantity) {
                totalValue += r[i].value;
                sumAmount += r[i].quantity;
            } else {
                break;
            }
        }
        
        int256 subQuantity = s.quantity - sumAmount;
        if(i < r.length && subQuantity > 0) {
            totalValue += subQuantity * (buyers[i].price - buyers[i].cost);
        }
        return totalValue;
    }
}