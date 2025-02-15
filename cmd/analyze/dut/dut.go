package dut

import (
	"fmt"
	"os"
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
		projectDir := os.ExpandEnv("$WORK")
		designFiles := os.ExpandEnv("-f $WORK/design/dut.f")

		top, _ := cmd.Flags().GetString("designTop")
		designDir := projectDir + "/design/"

		// pass the designfile(s) to slang and generate the design model
		designModel.GenerateSlangAST(designFiles, top, designDir, "dut.json")
		dut := designModel.LoadDesignFromSlangAST(designDir+"/dut.json", top, designDir)
		designModel.ExportToJSON(designDir+"/designModel.json", dut)
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
