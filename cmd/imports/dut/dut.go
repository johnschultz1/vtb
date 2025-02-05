package dut

import (
	"fmt"
	"os"
	"strings"
	"vtb/designModel"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var ImportCmd = &cobra.Command{
	Use:   "dut",
	Short: "imports dut information",
	Long:  `A dir structure will be created for you with a generated a dut wrapper and dut interface`,
	Run: func(cmd *cobra.Command, args []string) {
		// Project dir
		projectDir, _ := cmd.Flags().GetString("projectName")
		projectDir = os.ExpandEnv("$PROJECTSHOME") + os.ExpandEnv(projectDir)
		designFiles, _ := cmd.Flags().GetString(os.ExpandEnv("designFiles"))
		// Design Files Existence check
		if !(strings.Contains(designFiles, ".f") || strings.Contains(designFiles, ".F")) {
			panic("error, design files must be in a single .f or .F")
		} else {
			designFiles = "-f " + designFiles
		}
		top, _ := cmd.Flags().GetString("designTop")
		designDir := projectDir + "/design/"

		// pass the designfile(s) to slang and generate the design model
		designModel.GenerateSlangAST(designFiles, top, os.ExpandEnv(designDir), "dut.json")
		dut := designModel.LoadDesignFromSlangAST(os.ExpandEnv(designDir)+"/dut.json", top, designDir)
		designModel.ExportToJSON(os.ExpandEnv(designDir)+"/designModel.json", dut)
		designModel.GenDutWrapper(dut, projectDir, top, "sv", designFiles)

		fmt.Printf("Design model successfully exported to %s\n", projectDir)
	},
}

func init() {
	//CreateCmd.AddCommand(project.ProjectCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:

}
