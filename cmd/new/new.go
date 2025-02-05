/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package new

import (
	"vtb/cmd/new/proj"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var NewCmd = &cobra.Command{
	Use:   "new",
	Short: "Use to create a new vtb item",
	Long:  ` vtb new proj [options]`,
}

func init() {
	NewCmd.AddCommand(proj.ProjCmd)
	proj.ProjCmd.Flags().StringP("projectName", "p", "", "Name of project to be placed in $PROJECTSHOME")
	proj.ProjCmd.MarkFlagRequired("projectName")
}
