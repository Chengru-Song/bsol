package main

import (
	"encoding/csv"
	"log"
	"os"
)

func ParseCSV(titles []string, records [][]string, filename string) (bool, error) {
	csvFile, err := os.Create(filename)
	if err != nil {
		log.Fatalf("error while creating file, err: %+v", err)
		return false, err
	}
	defer csvFile.Close()
	writer := csv.NewWriter(csvFile)
	if err := writer.Write(titles); err != nil {
		log.Fatalf("error while saving titles, err: %+v", err)
		return false, err
	}
	for _, record := range records {
		if err := writer.Write(record); err != nil {
			log.Fatalf("error while saving titles, err: %+v", err)
			return false, err
		}
	}

	writer.Flush()

	if err = writer.Error(); err != nil {
		log.Fatalf("error while flushing to file, err: %+v", err)
		return false, err
	}

	return true, nil
}
