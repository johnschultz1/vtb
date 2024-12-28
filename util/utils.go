package util

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
)

// Function to raise an int to a power
func Power(base, exponent int) int {
	result := 1
	for i := 0; i < exponent; i++ {
		result *= base
	}
	return result
}

// error check
func ErrCheck(err error, msg string) {
	if err != nil {
		fmt.Printf("error occured checking %s", msg)
		panic(err)
	}
}

// intToHex converts an integer to a hexadecimal string with optional padding and case.
func IntToHex(number int, padding int, uppercase bool) string {
	var format string
	if uppercase {
		format = fmt.Sprintf("%%0%dx", padding) // Use %% to escape the %
	} else {
		format = fmt.Sprintf("%%0%dx", padding) // Use %% to escape the %
	}

	if uppercase {
		return fmt.Sprintf(format, number)
	}
	return fmt.Sprintf(format, number)
}

func IntToString(integer int) string {
	return strconv.Itoa(integer)
}

func IntArrayToStringArray(numbers []int) []string {
	var strs []string
	for _, integer := range numbers {
		strs = append(strs, IntToString(integer))
	}
	return strs
}

// CreateDirs creates all intermediate directories if they don't exist
func CreateDirs(path string) error {
	// MkdirAll creates a directory along with any necessary parents
	err := os.MkdirAll(path, os.ModePerm) // ModePerm grants full permissions (0777)
	if err != nil {
		return err
	}
	return nil
}

// copyFile copies a single file from src to dst
func copyFile(src, dst string) {
	srcFile, err := os.Open(src)
	ErrCheck(err, "failed to open source file")
	defer srcFile.Close()

	dstFile, err := os.Create(dst)
	ErrCheck(err, "failed to create destination file")
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	ErrCheck(err, "failed to copy file content")

	err = dstFile.Sync()
	ErrCheck(err, "failed to flush destination file")
}

func copyDirectory(srcDir, dstDir string) {
	err := filepath.Walk(srcDir, func(path string, info os.FileInfo, err error) error {
		ErrCheck(err, "failed to access path during directory walk")

		// Compute the destination path
		relPath, err := filepath.Rel(srcDir, path)
		ErrCheck(err, "failed to compute relative path")
		dstPath := filepath.Join(dstDir, relPath)

		if info.IsDir() {
			// Create the directory structure in the destination
			err := os.MkdirAll(dstPath, info.Mode())
			ErrCheck(err, "failed to create directory")
		} else {
			// If it's a file, copy it
			copyFile(path, dstPath)
		}
		return nil
	})
	ErrCheck(err, "failed to walk source directory")
}

// Copy handles both file and directory copying
func Copy(src, dst string) {
	info, err := os.Stat(src)
	ErrCheck(err, "failed to stat source path")

	if info.IsDir() {
		// If src is a directory, copy recursively
		copyDirectory(src, dst)
	} else {
		// If src is a file, copy it
		copyFile(src, dst)
	}
}
