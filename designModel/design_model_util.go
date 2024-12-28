package designModel

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"text/template"
	"vtb/util"
)

func GenerateSlangAST(designFiles string, designTop string, outputDir string, fileName string) {
	slangEXE := os.ExpandEnv("$SLANGEXE")
	slangOpts := os.ExpandEnv("$SLANGOPTS")
	cmd := exec.Command("bash", "-c", fmt.Sprintf("%s --top %s %s -ast-json %s/%s %s", slangEXE, designTop, slangOpts, outputDir, fileName, designFiles))
	cmd.Dir = "./"
	output, err := cmd.CombinedOutput()
	util.ErrCheck(err, string(output))
}

func LoadDesignFromSlangAST(ast_filename string, design_top string, dir string) DesignModel {
	design := new(DesignModel)
	ast_converter := NewASTScraper(true, design_top, dir)
	ast_converter.ParseAST(ast_filename, design)
	return *design
}

// ExportDesignModelToJSON exports the design model to a JSON file
func ExportToJSON(filename string, design DesignModel) error {
	// Convert designModel to JSON with indentation
	jsonData, err := json.MarshalIndent(design, "", "  ")
	util.ErrCheck(err, "error marshalling design model to JSON")

	// Open or create the file
	file, err := os.Create(filename)
	util.ErrCheck(err, "error creating file")
	defer file.Close()

	// Write JSON data to the file
	_, err = file.Write(jsonData)
	util.ErrCheck(err, "error creating file")

	return nil
}

// import designModel from a json file
func ImportFromJSON(filename string) *DesignModel {
	newDesign := new(DesignModel)
	// Read the file contents using os.ReadFile
	byteValue, err := os.ReadFile(filename)
	util.ErrCheck(err, "error reading file")

	// Unmarshal the JSON data into the struct
	err = json.Unmarshal(byteValue, &newDesign)
	util.ErrCheck(err, "error unmarshalling JSON")

	return newDesign
}

func GenDutWrapper(design DesignModel, projectDir string, top string, fileType string, dutFiles string) {
	// Parse the SystemVerilog template for instances
	if fileType == "sv" {
		// Helper function for template
		funcMap := template.FuncMap{
			"sub1":             func(i int) int { return i - 1 },
			"maxTypeWidth":     maxTypeWidth,
			"maxNameWidth":     maxNameWidth,
			"pad":              pad,
			"getDirection":     getDirection, // Add the helper function
			"containsBrackets": containsBrackets,
			"zeroExtend":       zeroExtend,
			"extractBits":      extractBits,
			"addQuotes":        addQuotes,
			"maxAssignWidth":   maxAssignWidth,
			"maxLineWidth":     maxLineWidth,
			"add":              add,
		}
		// Parse the interface templates with the helper functions
		tmpl, err := template.New("dutWrapper.sv.tpl").Funcs(funcMap).ParseFiles(os.ExpandEnv("$VTBHOME/src/goTemplates/dutWrapper.sv.tpl"))
		util.ErrCheck(err, "failed to parse template file")
		interfaceTmpl, err := template.New("dutInterface.sv.tpl").Funcs(funcMap).ParseFiles(os.ExpandEnv("$VTBHOME/src/goTemplates/dutInterface.sv.tpl"))
		util.ErrCheck(err, "failed to parse template file")

		topComponent := GetDesignComponentByName(top, &design)

		// create dut wrapper
		outputFile, err := os.Create(os.ExpandEnv(projectDir) + "/design/dutWrapper.sv")
		util.ErrCheck(err, "failed to create output file")
		err = tmpl.Execute(outputFile, topComponent)
		util.ErrCheck(err, "failed to create output file")
		defer outputFile.Close()

		// create the dut interface
		interfaceFile, err := os.Create(os.ExpandEnv(projectDir) + "/design/dutInterface.sv")
		util.ErrCheck(err, "failed to create output file")
		err = interfaceTmpl.Execute(interfaceFile, topComponent)
		util.ErrCheck(err, "failed to create output file")
		defer interfaceFile.Close()

		// create project env file
		envFile := os.ExpandEnv(projectDir) + "/projEnv.sh"
		// Open the file for writing, creating it if it doesn't exist, or truncating it if it does
		file, _ := os.OpenFile(envFile, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0770)
		file.WriteString("export PROJECTDIR=" + projectDir + "\n")
		// includes to pass to verilator
		file.WriteString("export VERIINC='-I$VERIHOME/include -I$VTBHOME/src -I$PROJECTDIR/verif/run/vtb'")
		defer file.Close()

		// create design .f file
		designSrcFile := os.ExpandEnv(projectDir) + "/design/src.f"
		// Open the file for writing, creating it if it doesn't exist, or truncating it if it does
		file, _ = os.OpenFile(designSrcFile, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0770)
		file.WriteString(dutFiles + "\n")
		file.WriteString("$PROJECTDIR//design/dutInterface.sv" + "\n")
		file.WriteString("$PROJECTDIR//design/dutWrapper.sv" + "\n")
		defer file.Close()
	}
}

func GetDesignComponentByHier(hierarchy string, design *DesignModel) *Component {
	for _, component := range design.Components {
		if component.Hierarchy == hierarchy {
			return component
		}
	}
	return nil
}

func GetDesignComponentByName(componentName string, design *DesignModel) *Component {
	for _, component := range design.Components {
		if component.Name == componentName {
			return component
		}
	}
	return nil
}

func GetComponentPortByName(portName string, component *Component) *Port {
	for _, port := range component.Ports {
		if port.Name == portName {
			return port
		}
	}
	return nil
}

func AddSignal(name string, signalType string, hier string, component *Component) {
	newSig := Signal{
		Name:      name,
		Type:      signalType,
		Hierarchy: hier,
	}
	component.Signals = append(component.Signals, &newSig)
}

func AddPort(name string, portType string, hier string, dir string, component *Component) {
	newPort := Port{
		Name:      name,
		Type:      portType,
		Dir:       dir,
		Hierarchy: hier,
	}
	component.Ports = append(component.Ports, &newPort)
}

func AddInterface(name string, ports []*Port, component *Component) {
	newInf := Interface{
		Name:  name,
		Ports: ports,
	}
	component.Interfaces = append(component.Interfaces, &newInf)
}

func AddSubComponent(name string, subType string, hier string, component *Component) {
	newSubC := SubComponent{
		Name:      name,
		Type:      subType,
		Hierarchy: hier,
	}
	component.SubComponents = append(component.SubComponents, &newSubC)
}

func CreateConnection(kind string, connType string, hier string, name string) *Connection {
	newConn := Connection{
		Component: hier,
		VarName:   name,
		VarType:   connType,
		VarKind:   kind,
	}
	return &newConn
}

//func (design *proto_design_model.DesignModel) ComponentExists(componentHierarchicalName string) bool {
//	component := design.TopComponentMap[componentHierarchicalName]
//	if component == nil {
//		return false
//	} else {
//		return true
//	}
//}

func AddFanIn(name string, conn *Connection, component *Component) {
	// Ensure the key exists in the map
	if component.FanInConnMap == nil {
		// Double-check that the map itself is not nil
		component.FanInConnMap = make(map[string]*ConnectionList)
	}
	// Check if the key exists in the map
	if component.FanInConnMap[name] == nil {
		// If not, initialize `DiffObject` with an empty slice
		component.FanInConnMap[name] = &ConnectionList{Connections: []*Connection{}}
	}
	component.FanInConnMap[name].Connections = append(component.FanInConnMap[name].Connections, conn)
}
func AddFanOut(name string, conn *Connection, component *Component) {

	if component.FanOutConnMap == nil {
		// Double-check that the map itself is not nil
		component.FanOutConnMap = make(map[string]*ConnectionList)
	}
	if component.FanOutConnMap[name] == nil {
		// If not, initialize `DiffObject` with an empty slice
		component.FanOutConnMap[name] = &ConnectionList{Connections: []*Connection{}}
	}
	component.FanOutConnMap[name].Connections = append(component.FanOutConnMap[name].Connections, conn)
}

const (
	IN    string = "In"
	OUT   string = "Out"
	INOUT string = "InOut"
	BIT   string = "bit"
)

func PortTypeToWidth(p Port) []int {
	var integers []int

	if p.Type == BIT {
		integers = append(integers, 1)
		return integers
	} else if strings.Contains(strings.ToLower(p.Type), strings.ToLower("[")) {
		// Input string
		str := p.Type

		// Regular expression to match both [number] and [number:number] patterns
		re := regexp.MustCompile(`\[(\d+)(?::(\d+))?\]`)

		// Find all matches
		matches := re.FindAllStringSubmatch(str, -1)

		// Loop through matches and apply the conversion rule
		for _, match := range matches {
			// Convert the first captured group to an integer
			x, _ := strconv.Atoi(match[1])

			// If there's a second group (from [number:number])
			if match[2] != "" {
				y, _ := strconv.Atoi(match[2])

				// Apply the rule: (x - y) + 1 unless x == y, then return 1
				if x == y {
					integers = append(integers, 1)
				} else {
					integers = append(integers, (x-y)+1)
				}
			} else {
				// For single numbers like [3], just add x to the list
				integers = append(integers, x)
			}
		}
		return integers
	} else {
		return nil
	}
}

func NewComponent() *Component {
	comp := &Component{
		Name:          "",
		Type:          "",
		Hierarchy:     "",
		Signals:       []*Signal{},
		Ports:         []*Port{},
		Interfaces:    []*Interface{},
		SubComponents: []*SubComponent{},
		FanInConnMap:  make(map[string]*ConnectionList),
		FanOutConnMap: make(map[string]*ConnectionList),
	}
	return comp
}

// Helper functions for templates
func maxTypeWidth(ports []*Port) int {
	max := 0
	for _, port := range ports {
		if len(port.GetType()) > max {
			max = len(port.GetType())
		}
	}
	return max
}

func maxNameWidth(ports []*Port) int {
	max := 0
	for _, port := range ports {
		if len(port.GetName()) > max {
			max = len(port.GetName())
		}
	}
	return max
}

func getDirection(dir string) string {
	if dir == "In" {
		return "input"
	}
	return "output"
}

func containsBrackets(s string) bool {
	return strings.Contains(s, "[")
}

func pad(s string, width int) string {
	return fmt.Sprintf("%-*s", width, s) // Left-align the string with padding
}

func zeroExtend(name string, typ string) string {
	if !strings.Contains(typ, "[") { // Single-bit signal
		return fmt.Sprintf("{31'b0, %s}", name)
	}

	// Parse the bit range, e.g., "logic[7:0]"
	openBracket := strings.Index(typ, "[")
	closeBracket := strings.Index(typ, "]")
	if openBracket == -1 || closeBracket == -1 {
		return name // Default to no zero-extension if brackets are missing
	}

	// Extract the range and calculate width
	rangeStr := typ[openBracket+1 : closeBracket] // e.g., "7:0"
	parts := strings.Split(rangeStr, ":")
	if len(parts) != 2 {
		return name // Default to no zero-extension if range parsing fails
	}

	msb, err1 := strconv.Atoi(parts[0])
	lsb, err2 := strconv.Atoi(parts[1])
	if err1 != nil || err2 != nil || msb < lsb {
		return name // Default to no zero-extension if range is invalid
	}

	width := msb - lsb + 1
	zeroBits := 32 - width
	if zeroBits > 0 {
		return fmt.Sprintf("{%d'b0, %s}", zeroBits, name)
	} else {
		return name
	}
}

func extractBits(typ string, value string) string {
	if !strings.Contains(typ, "[") {
		// Single-bit signal
		return fmt.Sprintf("%s[0]", value)
	}

	// Parse the bit range, e.g., "logic[7:0]"
	openBracket := strings.Index(typ, "[")
	closeBracket := strings.Index(typ, "]")
	if openBracket == -1 || closeBracket == -1 {
		return value // Default to full value if no brackets
	}

	// Extract the range and calculate width
	rangeStr := typ[openBracket+1 : closeBracket] // e.g., "7:0"
	parts := strings.Split(rangeStr, ":")
	if len(parts) != 2 {
		return value // Default to full value if range parsing fails
	}

	msb, err1 := strconv.Atoi(parts[0])
	lsb, err2 := strconv.Atoi(parts[1])
	if err1 != nil || err2 != nil || msb < lsb {
		return value // Default to full value if range is invalid
	}

	width := msb - lsb + 1
	return fmt.Sprintf("%s[%d:0]", value, width-1)
}

func addQuotes(width int) int {
	return width + 3 // Quotes (") and colon (:)
}

func maxAssignWidth(ports []*Port) int {
	max := 0
	for _, port := range ports {
		// Calculate width of "signal_name = value[31:0];"
		assign := fmt.Sprintf("%s = value[31:0];", port.Name)
		if len(assign) > max {
			max = len(assign)
		}
	}
	return max
}

func maxLineWidth(ports []*Port) int {
	max := 0
	for _, port := range ports {
		line := fmt.Sprintf("\"%s\": %s = value[31:0];", port.Name, port.Name)
		if len(line) > max {
			max = len(line)
		}
	}
	return max
}
func add(a int, b int) int { return (a + b) }
