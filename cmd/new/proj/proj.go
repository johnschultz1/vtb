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
		projectName, _ := cmd.Flags().GetString("projectName")
		projectsHome, _ := cmd.Flags().GetString("projectsHome")
		projectDir := os.ExpandEnv(projectsHome) + os.ExpandEnv(projectName)
		util.CreateDirs(projectDir)
		designDir := projectDir + "/design/"
		util.CreateDirs(designDir)

		// cp testbench template to project directory
		sourceFile := os.ExpandEnv("$VTBHOME/src/projectTemplate/")
		destFile := os.ExpandEnv(projectDir)
		util.Copy(sourceFile, destFile)

		// create project .env file
		envFile := os.ExpandEnv(projectDir) + "/.env"
		// Open the file for writing, creating it if it doesn't exist, or truncating it if it does
		file, _ := os.OpenFile(envFile, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0770)
		work := os.ExpandEnv(projectsHome) + os.ExpandEnv(projectName) + "/"
		file.WriteString("PROJECTSHOME=" + os.ExpandEnv(projectsHome) + "\n")
		file.WriteString("PROJECTNAME=" + os.ExpandEnv(projectName) + "\n")
		file.WriteString("WORK=" + work + "\n")
		file.WriteString("YAMLFILES=" +
			"$WORK/verif/config/yaml/*.yaml,\\\n" +
			"$WORK/verif/scenarios/yaml/*.yaml" + "\\\n")
		defer file.Close()

		fmt.Printf("Project successfully generated in %s\n", projectDir)
	},
}

func init() {
	ProjCmd.Flags().StringP("projectsHome", "d", "$PROJECTSHOME", "Name of home to put projects in")
	ProjCmd.Flags().StringP("projectName", "n", "$PROJECTNAME", "Name of project in $PROJECTSHOME")
}
