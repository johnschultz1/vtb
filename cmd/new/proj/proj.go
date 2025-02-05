package proj

import (
	"fmt"
	"os"
	"vtb/util"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var ProjCmd = &cobra.Command{
	Use:   "proj",
	Short: "create new project",
	Long:  `A dir structure will be created for you with a generated with $PROJECTSHOME`,
	Run: func(cmd *cobra.Command, args []string) {
		projectDir, _ := cmd.Flags().GetString("projectName")
		projectDir = os.ExpandEnv("$PROJECTSHOME") + projectDir
		util.CreateDirs(projectDir)
		designDir := projectDir + "/design/"
		util.CreateDirs(designDir)

		// cp testbench template to project directory
		sourceFile := os.ExpandEnv("$VTBHOME/src/projectTemplate/")
		destFile := os.ExpandEnv(projectDir)
		util.Copy(sourceFile, destFile)

		fmt.Printf("Project successfully generated in %s\n", projectDir)
	},
}

func init() {
}
