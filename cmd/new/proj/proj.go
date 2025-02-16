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
	Long:  `A dir structure will be created for you within the passed dir location`,
	Run: func(cmd *cobra.Command, args []string) {

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

		// create project .proj file
		projCfg := util.NewProjCfg()
		projFile := work + "/.proj"

		// Add vars to envFile
		projCfg.AddEnvVar("VTBHOME", vtbHome)
		projCfg.AddEnvVar("PROJECTNAME", projectName)
		projCfg.AddEnvVar("PROJECTSHOME", projectsHome)
		projCfg.AddEnvVar("CONTAINERHOME", "/VTB_PROJECTS/")
		projCfg.AddEnvVar("WORK", projectsHome+projectName)
		projCfg.AddEnvVar("DESIGN", "$WORK/design/")
		projCfg.AddEnvVar("VERIF", "$WORK/verif/")
		projCfg.AddEnvVar("TBNAME", "TB")
		projCfg.AddEnvVar("DESIGNFILES", "$WORK/design/dut.f")
		projCfg.AddEnvVar("DUTTOP", "top")
		projCfg.AddEnvVar("IMAGE_NAME", "vtb:v0")
		// Add yaml simfile locations
		projCfg.AddSimFileLocation("$VERIF/config/yaml/*.yaml")
		projCfg.AddSimFileLocation("$VERIF/scenarios/yaml/*.yaml")
		// Add Slang Options
		projCfg.AddSlangOption("--allow-toplevel-iface-ports")
		projCfg.AddSlangOption("-I$DESIGN/")
		projCfg.AddSlangOption("-I$WORK/")
		// Add Verilator Options
		projCfg.AddVerilatorOption("--cc --binary -CFLAGS \"-std=c++17 -lpthread \"")
		projCfg.AddVerilatorOption(" --debug --Wno-lint --sv --timing --trace --public --trace-structs")
		projCfg.AddVerilatorOption("-f $VERIF/src.f")
		projCfg.AddVerilatorOption("--Mdir $VERIF/run/vtb/")
		projCfg.AddVerilatorOption("-I$VERIF/run/vtb/")
		projCfg.AddVerilatorOption("-I$DESIGN/")
		projCfg.AddVerilatorOption("-I$VERIF/src/")
		projCfg.AddVerilatorOption("-I$VTBHOME/src/")
		projCfg.AddVerilatorOption("-top-module $TBNAME")

		projCfg.WriteYAMLFile(projFile)

		fmt.Printf("Project successfully generated in %s\n", projCfg.Vars["WORK"])
	},
}

func init() {
	ProjCmd.Flags().StringP("projectsHome", "d", "$HOME/VTB_PROJECTS/", "Name of dir to put project in")
	ProjCmd.Flags().StringP("projectName", "n", "newPrj", "Name of project in projectsHome dir")
}
