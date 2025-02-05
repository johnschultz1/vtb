package sim

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
	"vtb/designModel"

	"github.com/spf13/cobra"
)

// createCmd represents the create command
var SimCmd = &cobra.Command{
	Use:   "sim",
	Short: "run testbench",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		// check if project dir exists $PROJECTDIR
		//projectName, _ := cmd.Flags().GetString(os.ExpandEnv("projectName"))
		projectDir := os.ExpandEnv("$PROJECTSHOME/$PROJECTNAME")
		projectDir = projectDir + "/"
		info, err := os.Stat(projectDir)
		exists := err == nil && info.IsDir()
		if !exists {
			panic("Project Directory Does not exist")
		}
		// create input dir inside of run dir
		outputDir := projectDir + "/verif/run/"
		// check if it already exists

		// TODO add clean step option
		//info, err = os.Stat(outputDir)
		//exists = err == nil && info.IsDir()
		//if exists {
		// clean dir
		//os.RemoveAll(outputDir)
		//}
		// make dir
		//err = os.Mkdir(outputDir, 0770)
		//if err != nil {
		//	fmt.Printf("Er: %v", err)
		//}

		// parse YAML files
		scenario, _ := cmd.Flags().GetString(os.ExpandEnv("scenario"))
		files := projectDir + "/verif/config/yaml/*.yaml," + projectDir + "/verif/scenarios/yaml/*.yaml"
		fileList := strings.Split(files, ",")
		if err := designModel.LoadYamlFiles(fileList, projectDir, outputDir, scenario); err != nil {
			fmt.Printf("Error processing files: %v", err)
		}

		// Create or open a log file to write outputs
		buildLogFile, err := os.Create(outputDir + "build.log")
		if err != nil {
			fmt.Println("Error creating log file:", err)
			return
		}
		defer buildLogFile.Close()

		// Create or open a log file to write outputs
		simLogFile, err := os.Create(outputDir + "sim.log")
		if err != nil {
			fmt.Println("Error creating log file:", err)
			return
		}
		defer simLogFile.Close()

		// Command to execute
		options, _ := cmd.Flags().GetString(os.ExpandEnv("options"))
		veriBuildcmd := exec.Command("bash", "-c", "source "+projectDir+"/projectScripts/build.sh")
		veriSimcmd := exec.Command("bash", "-c", projectDir+"/verif/run/vtb/VTB +configFile="+projectDir+"/verif/run/config.csv +scenarioFile="+projectDir+"/verif/run/"+scenario+".csv "+options)

		// Create a multi-writer to write to both file and stdout
		buildLog := io.MultiWriter(os.Stdout, buildLogFile)
		veriBuildcmd.Stdout = buildLog
		veriBuildcmd.Stderr = buildLog

		simLog := io.MultiWriter(os.Stdout, simLogFile)
		veriSimcmd.Stdout = simLog
		veriSimcmd.Stderr = simLog

		// verilate
		if err := veriBuildcmd.Run(); err != nil {
			fmt.Println("Error executing command:", err)
		} else {
			// run sim
			if err := veriSimcmd.Run(); err != nil {
				fmt.Println("Error executing command:", err)
			}
		}
	},
}

func init() {
	//CreateCmd.AddCommand(project.ProjectCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this commaECTDIR/verif/config/yaml/*.yamlnd
	// is called directly, e.g.:
	//SimCmd.Flags().StringP("projectName", "p", "./", "location of project dir")
	//SimCmd.Flags().StringP("yamlFiles", "y", "$PROJECTDIR/verif/scenarios/yaml/*.yaml", "all yaml scenario/files")
	SimCmd.Flags().StringP("scenario", "s", "", "name of the scenario to run")
	SimCmd.Flags().StringP("options", "o", "", "runtime options")
	//SimCmd.MarkFlagRequired("projectName")
	SimCmd.MarkFlagRequired("scenario")
}
