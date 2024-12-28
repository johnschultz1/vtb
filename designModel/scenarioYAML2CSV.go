package designModel

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"vtb/util"

	"gopkg.in/yaml.v3"
)

type top struct {
	scenarios []Scenario
	configs   []Config
}

type topScenario struct {
	Top Scenario `yaml:"scenario"`
}

type topConfig struct {
	Top Config `yaml:"config"`
}

type Scenario struct {
	Name      string   `yaml:"name"`
	GlobalCfg []Global `yaml:"globalCfg"`
	Tasks     []Task   `yaml:"tasks"`
}

type Global struct {
	Name string `yaml:"name"`
}

type Task struct {
	Name         string       `yaml:"name"`
	CallName     string       `yaml:"callName"`
	Config       string       `yaml:"config"`
	Dependencies []Dependency `yaml:"dependencies"`
	Finishes     string       `yaml:"finishes"`
}

type Dependency struct {
	Name  string `yaml:"name"`
	Type  string `yaml:"type"`
	MsgID string `yaml:"msgID,omitempty"`
}

type Config struct {
	Name string     `yaml:"name"`
	Vars []Variable `yaml:"vars"`
}

type Variable struct {
	Name   string      `yaml:"name"`
	Type   string      `yaml:"type"`
	Value  interface{} `yaml:"value,omitempty"`
	Values []string    `yaml:"values,omitempty"`
}

func getFilenameWithoutSuffix(path string) string {
	base := filepath.Base(path)                         // Get the leaf filename
	return strings.TrimSuffix(base, filepath.Ext(base)) // Remove the extension
}

// GetFileList processes a list of filenames and patterns, returning a list of resolved files
func GetFileList(filePatterns []string) []string {
	var resolvedFiles []string

	for _, pattern := range filePatterns {
		// Check for wildcard patterns
		expandedPattern := os.ExpandEnv(pattern)
		matchedFiles, err := filepath.Glob(expandedPattern)
		util.ErrCheck(err, fmt.Sprintf("error matching pattern %s", expandedPattern))

		if matchedFiles != nil {
			// Add matched files from wildcard
			resolvedFiles = append(resolvedFiles, matchedFiles...)
		} else {
			// Add explicit file
			resolvedFiles = append(resolvedFiles, expandedPattern)
		}
	}

	return resolvedFiles
}

func LoadYamlFiles(filePatterns []string, projectDir string, outputDir string, top string) error {
	fileList := GetFileList(filePatterns)
	for _, filename := range fileList {
		file, err := os.Open(filename)
		if err != nil {
			return fmt.Errorf("failed to open file %s: %w", filename, err)
		}
		defer file.Close()

		decoder := yaml.NewDecoder(file)

		for {
			var root map[string]interface{}
			if err := decoder.Decode(&root); err != nil {
				if err == io.EOF {
					break // End of file or documents
				}
				return fmt.Errorf("failed to decode YAML in file %s: %w", filename, err)
			}

			// Process each document
			if _, isScenario := root["scenario"]; isScenario {
				var scenario Scenario
				raw, _ := yaml.Marshal(root["scenario"])
				if err := yaml.Unmarshal(raw, &scenario); err != nil {
					return fmt.Errorf("failed to decode scenario in file %s: %w", filename, err)
				}
				// Create CSV for scenario
				print("\n\n making making \n\n")
				if err := writeScenarioToCSV(&scenario, outputDir+getFilenameWithoutSuffix(scenario.Name)+".csv"); err != nil {
					return fmt.Errorf("failed to write scenario CSV for file %s: %w", filename, err)
				}

				// create task factory if its the top scenario
				if scenario.Name == top {
					generateFactory(projectDir, scenario)
				}
			} else if _, isConfig := root["config"]; isConfig {
				var config Config
				print("found cfg")
				raw, _ := yaml.Marshal(root["config"])
				if err := yaml.Unmarshal(raw, &config); err != nil {
					return fmt.Errorf("failed to decode config in file %s: %w", filename, err)
				}
				// Create CSV for config
				if err := writeConfigToCSV(config, outputDir+"config.csv"); err != nil {
					return fmt.Errorf("failed to write config CSV for file %s: %w", filename, err)
				}
			} else {
				return fmt.Errorf("unknown YAML document type in file %s", filename)
			}
		}
	}
	return nil
}

func generateFactory(projectDir string, scenario Scenario) {
	// Parse the interface templates with the helper functions
	tmpl, err := template.New("taskFactory.tpl").ParseFiles(os.ExpandEnv("$VTBHOME/src/goTemplates/taskFactory.tpl"))
	util.ErrCheck(err, "failed to parse template file")

	// create factory
	outputFile, err := os.Create(os.ExpandEnv(projectDir) + "/design/taskFactory.sv")
	util.ErrCheck(err, "failed to create output file")
	// remove tasks with duplicate call names, no need for them
	scenario.Tasks = RemoveDuplicates(scenario.Tasks)
	err = tmpl.Execute(outputFile, scenario)
	util.ErrCheck(err, "failed to create output file")
	defer outputFile.Close()
}

func RemoveDuplicates(tasks []Task) []Task {
	seen := make(map[string]bool)
	var result []Task

	for _, task := range tasks {
		if !seen[task.CallName] {
			result = append(result, task)
			seen[task.CallName] = true
		}
	}
	return result
}

func writeConfigToCSV(cfg Config, filename string) error {
	file, err := os.OpenFile(filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644) // Base permissions
	if err != nil {
		return fmt.Errorf("failed to open CSV file: %w", err)
	}
	defer file.Close()

	// Force the correct permissions regardless of UMASK or existing file permissions
	if err := os.Chmod(filename, 0775); err != nil {
		return fmt.Errorf("failed to set file permissions: %w", err)
	}

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Check if the file is empty to write the header
	fileInfo, err := file.Stat()
	if err != nil {
		return fmt.Errorf("failed to get file info: %w", err)
	}

	if fileInfo.Size() == 0 { // Write header only if the file is empty
		header := []string{"ConfigName", "VarName", "VarType", "Value", "Values"}
		if err := writer.Write(header); err != nil {
			return fmt.Errorf("failed to write header: %w", err)
		}
	}

	// Write config and variable data
	for _, variable := range cfg.Vars {
		row := []string{
			cfg.Name,
			variable.Name,
			variable.Type,
			fmt.Sprintf("%v", variable.Value),
			fmt.Sprintf("%v", variable.Values),
		}
		if err := writer.Write(row); err != nil {
			return fmt.Errorf("failed to write row: %w", err)
		}
	}

	return nil
}

func writeScenarioToCSV(scenario *Scenario, filename string) error {
	file, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY, 0644) // Base permissions
	if err != nil {
		return fmt.Errorf("failed to open CSV file: %w", err)
	}
	defer file.Close()

	// Force the correct permissions regardless of UMASK or existing file permissions
	if err := os.Chmod(filename, 0775); err != nil {
		return fmt.Errorf("failed to set file permissions: %w", err)
	}

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	header := []string{"TaskName", "CallName", "Config", "DependencyName", "DependencyType", "MsgID", "Finishes"}
	if err := writer.Write(header); err != nil {
		return fmt.Errorf("failed to write header: %w", err)
	}

	// Write task data
	for _, task := range scenario.Tasks {
		finishes := "true"
		if task.Finishes != "" {
			finishes = task.Finishes
		}
		if len(task.Dependencies) == 0 {
			row := []string{task.Name, task.CallName, task.Config, "", "", "", finishes}
			if err := writer.Write(row); err != nil {
				return fmt.Errorf("failed to write task row: %w", err)
			}
		} else {
			for _, dep := range task.Dependencies {
				row := []string{task.Name, task.CallName, task.Config, dep.Name, dep.Type, dep.MsgID, finishes}
				if err := writer.Write(row); err != nil {
					return fmt.Errorf("failed to write dependency row: %w", err)
				}
			}
		}
	}

	return nil
}
