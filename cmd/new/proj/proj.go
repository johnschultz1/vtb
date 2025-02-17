package proj

import (
	"fmt"
	"os"
	"path/filepath"
	"vtb/util"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var ProjCmd = &cobra.Command{
	Use:   "proj",
	Short: "create new project",
	Long: `A dir structure will be created for you within the passed dir location. 

	A .proj file with configuration settings will be generated. This can be used to configure the project for the
	specific use case. 

	A .proj file can also be passed and used as a configuration template. 
	The project name and project directory will be updated with whatever is passed.`,
	Run: func(cmd *cobra.Command, args []string) {
		projectFile, _ := cmd.Flags().GetString("projectFile")
		projectName, _ := cmd.Flags().GetString("projectName")
		projectsHome, _ := cmd.Flags().GetString("projectsHome")
		projectName = os.ExpandEnv(projectName)
		projectsHome = os.ExpandEnv(projectsHome)

		// Get the path of the executable
		vtbHome, _ := os.Executable()
		// remove exe name
		vtbHome = filepath.Dir(vtbHome)
		// Resolve any symlinks to get the real path
		vtbHome, _ = filepath.EvalSymlinks(vtbHome)
		vtbHome = os.ExpandEnv(vtbHome)

		work := projectsHome + projectName
		designDir := work + "/design/"

		util.CreateDirs(work)
		util.CreateDirs(designDir)

		// cp testbench template to project directory
		sourceFile := vtbHome + "/src/projectTemplate/"
		destFile := work
		util.Copy(sourceFile, destFile)

		// A .proj that is passesd will be used instead
		cfg := util.NewProjCfg()
		// create project .proj file
		newProjFile := work + "/.proj"

		if projectFile == "./.proj" {
			// Add vars to envFile
			cfg.AddEnvVar("VTBHOME", vtbHome)
			cfg.AddEnvVar("PROJECTNAME", projectName)
			cfg.AddEnvVar("PROJECTSHOME", projectsHome)
			cfg.AddEnvVar("CONTAINERHOME", "/VTB_PROJECTS/")
			cfg.AddEnvVar("WORK", projectsHome+projectName)
			cfg.AddEnvVar("DESIGN", "$WORK/design/")
			cfg.AddEnvVar("VERIF", "$WORK/verif/")
			cfg.AddEnvVar("TBNAME", "TB")
			cfg.AddEnvVar("DESIGNFILES", "$WORK/design/dut.f")
			cfg.AddEnvVar("DUTTOP", "top")
			cfg.AddEnvVar("IMAGE_NAME", "vtb:v0")
			// Add yaml simfile locations
			cfg.AddSimFileLocation("$VERIF/config/yaml/*.yaml")
			cfg.AddSimFileLocation("$VERIF/scenarios/yaml/*.yaml")
			// Add Slang Options
			cfg.AddSlangOption("--allow-toplevel-iface-ports")
			cfg.AddSlangOption("-I$DESIGN/")
			cfg.AddSlangOption("-I$WORK/")
			// Add Verilator Options
			cfg.AddVerilatorOption("--cc --binary -CFLAGS \"-std=c++17 -lpthread \"")
			cfg.AddVerilatorOption(" --debug --Wno-lint --sv --timing --trace --public --trace-structs")
			cfg.AddVerilatorOption("-f $VERIF/src.f")
			cfg.AddVerilatorOption("--Mdir $VERIF/run/vtb/")
			cfg.AddVerilatorOption("-I$VERIF/run/vtb/")
			cfg.AddVerilatorOption("-I$DESIGN/")
			cfg.AddVerilatorOption("-I$VERIF/src/")
			cfg.AddVerilatorOption("-I$VTBHOME/src/")
			cfg.AddVerilatorOption("-top-module $TBNAME")
			// write file to proj location
			cfg.WriteYAMLFile(newProjFile)
		} else {
			// check if passed .proj exists
			_, err := os.Stat(projectFile)
			util.ErrCheck(err, "Project File does not exist, check -p argument ")
			// use passed proj as base
			cfg.LoadYAMLFile(projectFile)
			// update proj dir and name with passed information
			cfg.Vars["PROJECTNAME"] = projectName
			cfg.Vars["PROJECTSHOME"] = projectsHome
			cfg.Vars["WORK"] = projectsHome + projectName
			// write it to the new location
			cfg.WriteYAMLFile(newProjFile)
		}
		fmt.Printf("Project successfully generated in %s\n", cfg.Vars["WORK"])
	},
}

func init() {
	ProjCmd.Flags().StringP("projectsHome", "d", "$HOME/VTB_PROJECTS/", "Name of dir to put project in")
	ProjCmd.Flags().StringP("projectName", "n", "newPrj", "Name of project in projectsHome dir")
	ProjCmd.MarkFlagRequired("projectName")
}
