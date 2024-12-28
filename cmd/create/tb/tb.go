package tb

import (
	"fmt"
	"os"
	"strings"
	"vtb/designModel"
	"vtb/util"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var TbCmd = &cobra.Command{
	Use:   "tb",
	Short: "create verilator testbench",
	Long:  `A dir structure will be created for you with a generated a dut wrapper and dut interface`,
	Run: func(cmd *cobra.Command, args []string) {
		projectDir, _ := cmd.Flags().GetString("projectDir")
		util.CreateDirs(projectDir)
		designFiles, _ := cmd.Flags().GetString(os.ExpandEnv("designFiles"))

		if !(strings.Contains(designFiles, ".f") || strings.Contains(designFiles, ".F")) {
			panic("error, design files must be in a single .f or .F")
		} else {
			designFiles = "-f " + designFiles
		}

		top, _ := cmd.Flags().GetString("designTop")
		designDir := projectDir + "/design/"

		// cp testbench template to project directory
		sourceFile := os.ExpandEnv("$VTBHOME/src/projectTemplate/")
		destFile := os.ExpandEnv(projectDir)
		util.Copy(sourceFile, destFile)

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
	TbCmd.Flags().StringP("projectDir", "p", "", "location of project dir")
	TbCmd.Flags().StringP("designFiles", "f", "", "Pointer to design compile/elab file, can be source file or .F,...")
	TbCmd.Flags().StringP("designTop", "t", "", "name of the top level design module")
	TbCmd.MarkFlagRequired("projectDir")
	TbCmd.MarkFlagRequired("designFiles")
	TbCmd.MarkFlagRequired("designTop")
}
