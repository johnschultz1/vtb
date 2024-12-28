/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package create

import (
	"vtb/cmd/create/tb"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var CreateCmd = &cobra.Command{
	Use:   "create",
	Short: "Use to create a verilator testbench",
	Long:  ` vtb create tb [options]`,
	//Run: func(cmd *cobra.Command, args []string) {
	//	fmt.Println("create called")
	//},
}

func init() {
	CreateCmd.AddCommand(tb.TbCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// createCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle"))
}
