package designModel

import (
	"io/ioutil"
	"os"

	"github.com/sirupsen/logrus"
	"github.com/tidwall/gjson"
)

const (
	PORT          string = "Port"
	ASSIGN        string = "ContinuousAssign"
	VARIABLE      string = "Variable"
	INSTANCE      string = "Instance"
	INTERFACEPORT string = "InterfacePort"
)

// ASTScraper keeps track of internal symbols and converts the AST to the design model JSON
type ASTScraper struct {
	symbolMap map[string]*Connection // Maps internal symbols to ports for fan-in/fan-out lookup
	astData   []gjson.Result         // The AST data in JSON format
	Debug     bool
	Top       string // Top module to parse
}

// NewASTScraper initializes a new ASTScraper with an empty graph
func NewASTScraper(debug bool, top string, dir string) *ASTScraper {
	// Log to a file
	file, err := os.OpenFile(os.ExpandEnv(dir)+"/designModelGen.log", os.O_CREATE|os.O_WRONLY, 0666)
	if err == nil {
		logrus.SetOutput(file)
	} else {
		logrus.Infof("Failed to log to file, using default stderr")
	}
	return &ASTScraper{
		symbolMap: make(map[string]*Connection), // Maps internal symbols to ports for fan-in/fan-out lookup
		astData:   []gjson.Result{},             // The AST data in JSON format
		Debug:     debug,
		Top:       top, // Top module to parse
	}
}

// ParseAST parses the AST from a JSON file and generates the design model
func (scraper *ASTScraper) ParseAST(jsonPath string, design *DesignModel) {

	topComponent := NewComponent()

	data, err := ioutil.ReadFile(jsonPath)
	if err != nil {
		logrus.Fatalf("Error reading file: %v", err)
	}

	// Parse the AST JSON using gjson
	jsonData := gjson.ParseBytes(data)

	// Log the design object to confirm structure
	logrus.Debugf("Design Field: %s\n", jsonData.Get("design").String())

	// Parse the top-level "design.members"
	designMembers := jsonData.Get("design.members").Array()
	scraper.astData = designMembers
	// pass top module name
	topComponent.Name = scraper.Top
	topComponent.Type = scraper.Top
	topComponent.Hierarchy = "$root." + scraper.Top

	// Recursively parse all instances starting from the top instance's body members
	connecSearches := []func(){}
	scraper.parseModuleBody(designMembers, topComponent, design, scraper.Top, "$root", nil, &connecSearches)

	// Search for all the connections and add them to the design model
	for _, fn := range connecSearches {
		fn()
	}

}

// parseInstancesRecursively parses the body members (ports, signals, instances, interfaces) recursively
// a module or an interface could be parsed with this function
func (scraper *ASTScraper) parseModuleBody(
	designBody []gjson.Result,
	component *Component,
	design *DesignModel,
	findName string,
	hier string,
	inf *Interface,
	connectioncalls *[]func()) {

	if inf != nil {
		hier = hier + "." + inf.Name
	} else {
		hier = hier + "." + component.Name
	}

	// Find the instance body of a module specified
	moduleMembers := scraper.findBodyByName(designBody, findName)
	if !moduleMembers.Exists() {
		logrus.Fatalf("Error: Instance body for top instance '%s' not found in the design.", scraper.Top)
	}

	for i, member := range moduleMembers.Array() {
		memberName := member.Get("name").String()

		if memberName == "" && member.Get("kind").String() == "" {
			logrus.Warnf("Skipping unnamed member %d", i)
			continue
		}

		internalSymbol := member.Get("internalSymbol").String()
		kind := member.Get("kind").String()
		varType := member.Get("type").String()

		switch kind {
		case PORT:
			// Add the port to the module
			port := scraper.getSlangPort(member, hier)
			// Add to the PortSymbolMap for fan-in/fan-out lookup
			// check if there is an interface symbol
			if internalSymbol != "" {
				// create connection poiter for connecting later on
				conn := Connection{
					Component: component.Hierarchy,
					VarType:   varType,
					VarName:   port.Name,
					VarKind:   kind,
				}
				scraper.symbolMap[internalSymbol] = &conn
				logrus.Infof("Found Internal Symbol %s", internalSymbol)
			}

			logrus.Infof("Adding Port To Component: %s", port.Name)

			// Add the port to the module's list of ports
			component.Ports = append(component.Ports, port)

			// parsing interface body
			if inf != nil {
				inf.Ports = append(inf.Ports, port)
			}
		}
	}
	if inf == nil {
		design.Components = append(design.Components, component)
		logrus.Infof("Adding Module: %s", component.Name)
	}
}

func (scraper *ASTScraper) getSlangPort(member gjson.Result, hier string) *Port {

	port := Port{
		Name:      member.Get("name").String(),
		Type:      member.Get("type").String(),
		Dir:       member.Get("direction").String(),
		Hierarchy: hier + "." + member.Get("name").String(),
	}

	return &port
}

func (scraper *ASTScraper) getSlangSignal(member gjson.Result, hier string) *Signal {

	signal := Signal{
		Name:      member.Get("name").String(),
		Type:      member.Get("type").String(),
		Hierarchy: hier + "." + member.Get("name").String(),
	}

	return &signal
}

func (scraper *ASTScraper) getSlangSubComponent(member gjson.Result, hier string) *SubComponent {

	subComponent := SubComponent{
		Name:      member.Get("name").String(),
		Type:      member.Get("body.name").String(),
		Hierarchy: hier + "." + member.Get("name").String(),
	}
	return &subComponent
}

// findBodyByName looks for the body of an interface or instance by name in the AST
func (scraper *ASTScraper) findBodyByName(members []gjson.Result, targetName string) gjson.Result {

	// First Check top members
	for i, member := range members {
		memberName := member.Get("name").String()
		memberBodyName := member.Get("body.name").String()

		// Debugging: Log the search process for the target body
		logrus.Infof("Searching for body in member %d: %s %s", i, memberName, memberBodyName)

		// Check if the current member is the target instance or interface by name
		if memberName == targetName || memberBodyName == targetName {
			// Return the body of the instance or interface
			body := member.Get("body")
			if body.Exists() {
				logrus.Infof("Found body for: %s", targetName)
				return body.Get("members")
			}
		}
	}

	// If not found then do a recursive search
	for i, member := range members {
		memberName := member.Get("name").String()
		memberBodyName := member.Get("body.name").String()

		// Debugging: Log the search process for the target body
		logrus.Infof("Searching for body in member %d: %s %s", i, memberName, memberBodyName)

		// Recursively check body members
		bodyMembers := member.Get("body.members")
		if bodyMembers.Exists() {
			result := scraper.findBodyByName(bodyMembers.Array(), targetName)
			if result.Exists() {
				return result
			}
		}
	}
	// Return empty result if the target body is not found
	logrus.Infof("Body not found for: %s", targetName)
	return gjson.Result{}
}
