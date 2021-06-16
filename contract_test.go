package main

import (
	"flag"
	"math/big"
	"testing"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"github.com/ethereum/go-ethereum/consensus/ethash"
	"github.com/ethereum/go-ethereum/core"
	"github.com/ethereum/go-ethereum/core/rawdb"
	"github.com/ethereum/go-ethereum/core/vm"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethdb/memorydb"
	"github.com/ethereum/go-ethereum/params"
)

func TestDeployContract(t *testing.T) {
	t.Log("test deploy contract")
	// Configure and generate a sample block chain
	var (
		memDb   = memorydb.New()
		db      = rawdb.NewDatabase(memDb)
		key, _  = crypto.HexToECDSA("b71c71a67e1177ad4e901695e1b4b9ee17ae16c6668d313eac2f96dbcda3f291")
		address = crypto.PubkeyToAddress(key.PublicKey)
		gspec   = &core.Genesis{
			GasLimit: 800000000,
			Config: &params.ChainConfig{
				HomesteadBlock:      big.NewInt(0),
				EIP150Block:         big.NewInt(0),
				EIP155Block:         big.NewInt(0),
				EIP158Block:         big.NewInt(0),
				ByzantiumBlock:      big.NewInt(0),
				ConstantinopleBlock: big.NewInt(0),
				PetersburgBlock:     big.NewInt(0),
				IstanbulBlock:       big.NewInt(0),
			},
			Alloc: core.GenesisAlloc{
				address: {Balance: big.NewInt(9000000000000000000)},
			},
		}
	)
	engine := ethash.NewFaker()
	chainConfig, _, err := core.SetupGenesisBlock(db, gspec)
	if err != nil {
		t.Fatal(err)
	}
	blockchain, err := core.NewBlockChain(db, &core.CacheConfig{
		TrieDirtyDisabled: true,
	}, chainConfig, engine, vm.Config{}, nil)
	if err != nil {
		t.Fatal(err)
	}
	_ = blockchain.StateCache().TrieDB()
	// construct the first diff

	contractBackend := backends.NewSimulatedBackend(gspec.Alloc, gspec.GasLimit)
	transactOpts := bind.NewKeyedTransactor(key)
	transactOpts.GasPrice = big.NewInt(1)
	_ = transactOpts
	_ = contractBackend
	source := []string{"/Users/bytedance/Documents/codes/bsol/WeatherStorage.sol"}
	data, err := deployBenchmarks(contractBackend, transactOpts, source)
	if err != nil {
		t.Fatal(err)
	}
	runs := flag.Uint64("runs", 500, "Count of runs per execution to calculate average. Default: 1500")
	time := flag.Bool("execution-time", false, "calculate average execution time")
	err = executeBenchmarks(contractBackend, transactOpts, data, *runs, *time)
	if err != nil {
		t.Fatal(err)
	}
}
