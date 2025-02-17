/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"os"

	"github.com/spf13/cobra"

	"vtb/cmd/inspect"
	"vtb/cmd/new"
	"vtb/cmd/sim"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "VTB",
	Short: "Verilator Testbench generator",
	Long:  ``,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	// Run: func(cmd *cobra.Command, args []string) { },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {

	//rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.tb_arch.yaml)")
	rootCmd.PersistentFlags().StringP("projectFile", "p", "./.proj", ".proj file, defaults to ./.proj")

	// Add Subcmds
	rootCmd.AddCommand(new.NewCmd)
	rootCmd.AddCommand(inspect.InspectCmd)
	rootCmd.AddCommand(sim.SimCmd)
}
