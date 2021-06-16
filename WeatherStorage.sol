// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

contract BenchmarkStorage {
    
  struct Weather {
    uint insideTemperature;
    uint insideHumidity;
    uint windSpeed;
    uint windDirection;
    uint uv;
    uint rainRate;
  }

  mapping (uint => Weather[24]) weathers;
  mapping (uint => uint) indexes;

  address creator;
  address authority;

  constructor() {
    creator = msg.sender;
  }

  // test only
  function BenchmarkclearWeatherByAddr() public returns(uint) {
    uint addr = 0;
    delete weathers[addr];
    return 1;
  }

  function BenchmarkgetWeathersByAddr() public view returns(Weather[24] memory) {
    uint addr = 0;
    return weathers[addr];
  }

  function BenchmarksetWeather() public returns(uint) {
    uint addr = 0;
    uint insideTemperature = 1;
    uint insideHumidity = 50;
    uint windSpeed = 10;
    uint windDirection = 0;
    uint uv = 100;
    uint rainRate = 80;

    Weather memory sw;
    sw.insideTemperature = insideTemperature;
    sw.insideHumidity = insideHumidity;
    sw.windSpeed = windSpeed;
    sw.windDirection = windDirection;
    sw.uv = uv;
    sw.rainRate = rainRate;
    
    weathers[addr][indexes[addr]] = sw;
    indexes[addr] += 1;
    if (indexes[addr] == 24) {
        indexes[addr] = 0;
    }
    
    return 1;
  }
}
