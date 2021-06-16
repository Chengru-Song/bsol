package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/compiler"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/syndtr/goleveldb/leveldb/errors"
)

type ContractData struct {
	a            abi.ABI
	code         string
	names        []string
	contractName string
}

func deployBenchmarks(contractBackend *backends.SimulatedBackend, opts *bind.TransactOpts, path []string) ([]ContractData, error) {
	contracts, err := compiler.CompileSolidity("./solc-macos", path...)
	if err != nil {
		return nil, err
	}
	var data []ContractData
	for contractName, contract := range contracts {
		fmt.Println(contractName)
		if strings.Index(strings.Split(contractName, ":")[1], "Benchmark") != 0 {
			continue
		}
		var names []string
		abiData, err := json.Marshal(contract.Info.AbiDefinition.([]interface{}))
		if err != nil {
			return nil, err
		}
		abi, err := abi.JSON(bytes.NewBuffer(abiData))
		if err != nil {
			return nil, err
		}
		// fmt.Printf("abi: %+v\nabiData:%+v\n", abi, abiData)
		for _, method := range contract.Info.AbiDefinition.([]interface{}) {
			mapped := method.(map[string]interface{})
			if mapped["name"] == nil {
				if len(mapped["inputs"].([]interface{})) != 0 {
					return nil, errors.New("Invalid Benchmark: constructor should require 0 arguments")
				}
				continue
			}
			name := mapped["name"].(string)
			if strings.Index(name, "Benchmark") != 0 {
				continue
			}
			if len(mapped["inputs"].([]interface{})) != 0 {
				return nil, errors.New("Invalid Benchmark: %s: function should require 0 arguments, but it requires %d")
			}
			names = append(names, name)
		}
		if err != nil {
			return nil, err
		}
		data = append(data, ContractData{abi, contract.Code, names, strings.Split(contractName, ":")[1]})
	}
	contractBackend.Commit()
	return data, nil
}

func executeBenchmarks(contractBackend *backends.SimulatedBackend, opts *bind.TransactOpts, data []ContractData, runs uint64, isTime bool) error {
	// fmt.Printf("%+v\n", data)
	for _, contractData := range data {
		fmt.Printf("\nContract: %s", contractData.contractName)
		if len(contractData.names) == 0 {
			fmt.Printf(" (No Benchmarks)\n")
			continue
		} else {
			fmt.Println()
		}
		if isTime == false {
			runs = 1
		}
		for _, method := range contractData.names {
			// change this
			userCount := 1000
			var tx *types.Transaction
			var err error
			var i uint64
			var addresses []common.Address
			var totalTime float64
			for ; i < runs; i++ {
				addr, _, _, err := bind.DeployContract(opts, contractData.a, common.Hex2Bytes(contractData.code[2:]), contractBackend)
				if err != nil {
					return err
				}
				addresses = append(addresses, addr)
			}
			contractBackend.Commit()
			i = 0
			records := [][]string{}
			for ; i < runs; i++ {
				currentStart := time.Now()
				c := bind.NewBoundContract(addresses[i], contractData.a, contractBackend, contractBackend, contractBackend)
				if err != nil {
					return err
				}
				tx, err = c.Transact(opts, method)
				if err != nil {
					return err
				}
				elapsedTime := convertElapsedToNano(time.Since(currentStart).String())
				count := strconv.Itoa(userCount)
				elapsedTimeStr := fmt.Sprintf("%+v", elapsedTime)
				currGas := fmt.Sprintf("%+v", tx.Gas())
				iter := fmt.Sprintf("%d", i)
				records = append(records, []string{count, elapsedTimeStr, currGas, iter})
			}
			if isTime {
				start := time.Now()
				contractBackend.Commit()
				totalTime = convertElapsedToNano(time.Since(start).String())
			} else {
				contractBackend.Commit()
			}

			fmt.Printf("Method: %s.%s()\n", contractData.contractName, method)
			if isTime {
				fmt.Printf("Average Computation time: %fµs\n", totalTime/float64(runs))
			}

			filename := fmt.Sprintf("%+v_%+v_benchmark.csv", contractData.contractName, runs)
			columnTitles := []string{"userCount", "timeConsumption", "gasUsage", "runTime"}
			_, err = ParseCSV(columnTitles, records, filename)
			if err != nil {
				return err
			}
			fmt.Printf("Gas Usage: %d Gas\n", tx.Gas())
			fmt.Printf("Gas Usage per execution: %d Gas\n", tx.Gas()-21000)
			if err != nil {
				return err
			}

		}
	}
	return nil
}
