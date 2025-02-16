package dut

import (
	"fmt"
	"os"
	"vtb/designModel"
	"vtb/util"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var ImportCmd = &cobra.Command{
	Use:   "dut",
	Short: "imports dut information",
	Long:  `A dir structure will be created for you with a generated a dut wrapper and dut interface`,
	Run: func(cmd *cobra.Command, args []string) {
		// Read in project configuration
		cfg := util.NewProjCfg()
		projectFile, _ := cmd.Flags().GetString("projectFile")
		cfg.LoadYAMLFile(projectFile)
		// Project dirs
		projectDir := cfg.GetVar("WORK")
		designFiles := util.RecursiveExpandEnv(cfg.Vars["DESIGNFILES"])
		_, err := os.Stat(designFiles)
		util.ErrCheck(err, "Design Files does not exist, check .proj file for location ")
		//
		top, _ := cmd.Flags().GetString("designTop")
		// use proj cfg designtop if an option is not passed
		if top == "" {
			top = cfg.Vars["DESIGNTOP"]
		} else {
			// update var with new one
			cfg.AddEnvVar("DUTTOP", top)
			cfg.WriteYAMLFile(projectFile)
		}
		designDir := cfg.GetVar("DESIGN")

		// pass the designfile(s) to slang and generate the design model
		// slang called from contianer so env not expanded here
		designModel.GenerateSlangAST(*cfg, cfg.Vars["DESIGNFILES"], top, cfg.Vars["DESIGN"], "dut.json")
		dut := designModel.LoadDesignFromSlangAST(designDir+"/dut.json", top, designDir)
		designModel.ExportToJSON(designDir+"/designModel.json", dut)
		designModel.GenDutWrapper(dut, projectDir, top, "sv", cfg.Vars["DESIGNFILES"])

		fmt.Printf("Design model successfully exported to %s\n", projectDir)
	},
}

func init() {
	ImportCmd.Flags().StringP("projectFile", "p", "./.proj", "Location of .proj file, defaults to ./")
	ImportCmd.Flags().StringP("designTop", "t", "", "name of the top level design module")

}
