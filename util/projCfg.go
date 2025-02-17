package util

import (
	"os"

	"gopkg.in/yaml.v3"
)

type ProjCfg struct {
	Vars             map[string]string `yaml:"vars"`
	SimFiles         []string          `yaml:"simFiles"`
	VerilatorOptions []string          `yaml:"verilatorOptions"`
	SlangOptions     []string          `yaml:"slangOptions"`
}

func NewProjCfg() *ProjCfg {
	return &ProjCfg{
		Vars:             make(map[string]string),
		SimFiles:         []string{},
		VerilatorOptions: []string{},
		SlangOptions:     []string{},
	}
}

func (cfg *ProjCfg) WriteYAMLFile(filePath string) {
	data, err := yaml.Marshal(cfg)
	ErrCheck(err, "Failed to write $WORK/.proj")
	err = os.WriteFile(filePath, data, 0644)
	ErrCheck(err, "Failed to write $WORK/.proj")
}

func (cfg *ProjCfg) LoadYAMLFile(filePath string) {
	data, err := os.ReadFile(filePath)
	ErrCheck(err, "Failed to open .proj\n")
	err = yaml.Unmarshal(data, &cfg)
	ErrCheck(err, "Failed to open .proj\n")

	// set values
	cfg.setEnv()
}

func (cfg *ProjCfg) setEnv() {
	for name, value := range cfg.Vars {
		os.Setenv(name, value)
	}
	// expand if needed
	for name, value := range cfg.Vars {
		envVar := RecursiveExpandEnv(value)
		os.Setenv(name, envVar)
	}
}

func RecursiveExpandEnv(s string) string {
	expanded := os.ExpandEnv(s)
	// Continue expanding until no changes occur.
	for expanded != s {
		s = expanded
		expanded = os.ExpandEnv(s)
	}
	return expanded
}

func (cfg *ProjCfg) GetVar(s string) string {
	return (os.ExpandEnv("$" + s))
}

func (cfg *ProjCfg) GetSlangOptions() string {
	var options string
	for _, value := range cfg.SlangOptions {
		options = options + value + " \\\n"
	}
	return options
}

func (cfg *ProjCfg) GetVerilatorOptions() string {
	var options string
	for _, value := range cfg.VerilatorOptions {
		options = options + value + " \\\n"
	}
	return options
}

func (cfg *ProjCfg) AddEnvVar(name string, value string) {
	cfg.Vars[name] = value
}

func (cfg *ProjCfg) AddSimFileLocation(value string) {
	cfg.SimFiles = append(cfg.SimFiles, value)
}

func (cfg *ProjCfg) AddVerilatorOption(value string) {
	cfg.VerilatorOptions = append(cfg.VerilatorOptions, value)
}

func (cfg *ProjCfg) AddSlangOption(value string) {
	cfg.SlangOptions = append(cfg.SlangOptions, value)
}
