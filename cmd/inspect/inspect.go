/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package inspect

import (
	"vtb/cmd/inspect/dut"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var InspectCmd = &cobra.Command{
	Use:   "inspect",
	Short: "Use to get information on an object",
	Long:  ` vtb import dut [options]`,
}

func init() {
	InspectCmd.AddCommand(dut.ImportCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// createCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle"))
}
