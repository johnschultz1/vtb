package util

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

func getCommandOutput(command string, args ...string) string {
	cmd := exec.Command(command, args...)
	out, err := cmd.CombinedOutput() // Capture both stdout and stderr
	if err != nil {
		fmt.Printf("Failed to run %s: %v\nOutput: %s", command, err, out)
	}
	return strings.TrimSpace(string(out))
}

func ExecuteDockerCmd(cfg ProjCfg, cmd string, cmdOptions string, logFile string) {
	// Get the user and group IDs
	uid := getCommandOutput("id", "-u")
	gid := getCommandOutput("id", "-g")
	cmdStr := cmd + " " + cmdOptions

	// Construct the --user argument
	userArg := fmt.Sprintf("%s:%s", uid, gid)
	args := []string{"run", "--rm", "--user", userArg}
	// mount location
	args = append(args, "-v", fmt.Sprintf("%s:%s", cfg.GetVar("PROJECTSHOME"), cfg.Vars["CONTAINERHOME"]))
	// env variables
	args = append(args, "-e", fmt.Sprintf("WORK=%s%s", cfg.Vars["CONTAINERHOME"], cfg.Vars["PROJECTNAME"]))
	args = append(args, "-e", fmt.Sprintf("PROJECTSHOME=%s", cfg.Vars["CONTAINERHOME"]))
	args = append(args, "-e", fmt.Sprintf("PROJECTNAME=%s", cfg.Vars["PROJECTNAME"]))
	args = append(args, "-e", fmt.Sprintf("DESIGN=%s%s%s", cfg.Vars["CONTAINERHOME"], cfg.Vars["PROJECTNAME"], "/design/"))
	args = append(args, "-e", fmt.Sprintf("VERIF=%s%s%s", cfg.Vars["CONTAINERHOME"], cfg.Vars["PROJECTNAME"], "/verif/"))
	args = append(args, "-e", fmt.Sprintf("TBNAME=%s", cfg.Vars["TBNAME"]))
	args = append(args, "-e", fmt.Sprintf("HOME=%s", "home/$(whoami)/"))
	args = append(args, cfg.Vars["IMAGE_NAME"], cmdStr)

	// Create Logfile
	buildLogFile, err := os.Create(logFile)
	ErrCheck(err, "Error creating log file")
	defer buildLogFile.Close()
	// EXEC
	execCmd := exec.Command("docker", args...)
	// Create a multi-writer to write to both file and stdout
	outputStream := io.MultiWriter(os.Stdout, buildLogFile)
	execCmd.Stdout = outputStream
	execCmd.Stderr = outputStream
	err = execCmd.Run()
	ErrCheck(err, string(fmt.Sprintf("Executing Command:\n%s", args)))

}
