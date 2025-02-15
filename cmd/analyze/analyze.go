/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package analyze

import (
	"vtb/cmd/analyze/dut"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var AnalyzeCmd = &cobra.Command{
	Use:   "analyze",
	Short: "Use to bring in external information",
	Long:  ` vtb import dut [options]`,
}

func init() {
	AnalyzeCmd.AddCommand(dut.ImportCmd)

	dut.ImportCmd.Flags().StringP("designTop", "t", "", "name of the top level design module")
	dut.ImportCmd.MarkFlagRequired("designTop")

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// createCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle"))
}
