package sim

import (
	"os"
	"vtb/designModel"
	"vtb/util"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var SimCmd = &cobra.Command{
	Use:   "sim",
	Short: "run testbench",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		// Read in project configuration
		cfg := util.NewProjCfg()
		projectFile, _ := cmd.Flags().GetString("projectFile")
		cfg.LoadYAMLFile(projectFile)

		// parse YAML files to create CSV files
		scenario, _ := cmd.Flags().GetString(os.ExpandEnv("scenario"))
		fileList := cfg.SimFiles
		err := designModel.LoadYamlFiles(fileList, cfg.GetVar("WORK"), cfg.GetVar("VERIF")+"/run/", scenario)
		util.ErrCheck(err, "Could not process sim yaml files")

		runSet, _ := cmd.Flags().GetBool("run")
		buildSet, _ := cmd.Flags().GetBool("build")

		// BUILD
		if buildSet == true {
			// Create Verilator Build String
			buildCmdString := cfg.GetVerilatorOptions()
			util.ExecuteDockerCmd(*cfg, "verilator", buildCmdString, cfg.GetVar("VERIF")+"/run/build.log")
		}
		// RUN
		if runSet == true {
			options, _ := cmd.Flags().GetString(os.ExpandEnv("options"))
			runCmdString := " $VERIF/run/vtb/VTB +configFile=$VERIF/run/config.csv " + " \\\n"
			runCmdString = runCmdString + " +scenarioFile=$VERIF/run/" + scenario + ".csv " + " \\\n"
			util.ExecuteDockerCmd(*cfg, "$VERIF/run/vtb/VTB", runCmdString+options, cfg.GetVar("VERIF")+"/run/sim.log")
		}
	},
}

func init() {
	SimCmd.Flags().StringP("scenario", "s", "", "name of the scenario to run")
	SimCmd.Flags().StringP("options", "o", "", "runtime options")
	SimCmd.Flags().BoolP("build", "b", false, "build option")
	SimCmd.Flags().BoolP("run", "r", false, "run option")
	SimCmd.Flags().StringP("projectFile", "p", "./.proj", "Location of .proj file, defaults to ./")
	SimCmd.MarkFlagRequired("scenario")
}
