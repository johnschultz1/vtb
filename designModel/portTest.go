package designModel

import (
	"testing"
	"vtb/util"
)

func TestTypeToPortWidth(t *testing.T) {
	p := Port{
		Name:      "blahg",
		Type:      "bit[1:0]",
		Dir:       "blah",
		Hierarchy: "blah.blah",
	}

	// Dimension 1, width 2
	portWidth := PortTypeToWidth(p)
	if len(portWidth) != 1 {
		t.Errorf("Port Width conversion Error")
	}
	for _, conv := range portWidth {
		if conv != 2 {
			t.Errorf("Port Width conversion Error")
		} else {
			t.Logf("PASS expected %d actual %d", 2, conv)
		}
	}

	// Dimension 1, width 1
	p.Type = "bit"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 1 {
		t.Errorf("Port Width conversion Error")
	}
	for _, conv := range portWidth {
		if conv != 1 {
			t.Errorf("Port Width conversion Error")
		} else {
			t.Logf("PASS expected %d actual %d", 1, conv)
		}
	}

	// Dimension 1, width 1
	p.Type = "bit[1:1]"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 1 {
		t.Errorf("Port Width conversion Error")
	}
	for _, conv := range portWidth {
		if conv != 1 {
			t.Errorf("Port Width conversion Error")
		} else {
			t.Logf("PASS expected %d actual %d", 1, conv)
		}
	}

	// Dimension 1, width 6
	p.Type = "bit[9:4]"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 1 {
		t.Errorf("Port Width conversion Error")
	}
	for _, conv := range portWidth {
		if conv != 6 {
			t.Errorf("Port Width conversion Error")
		} else {
			t.Logf("PASS expected %d actual %d", 6, conv)
		}
	}

	// Dimension 1, width 32
	p.Type = "bit[31:0]"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 1 {
		t.Errorf("Port Width conversion Error")
	}
	for _, conv := range portWidth {
		if conv != 32 {
			t.Errorf("Port Width conversion Error")
		} else {
			t.Logf("PASS expected %d actual %d", 32, conv)
		}
	}

	// Dimension 2, width 2,4
	p.Type = "bit[1:0][3:0]"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 2 {
		t.Errorf("Port Width conversion Error")
	}
	for i, conv := range portWidth {
		if conv != util.Power(2, i+1) {
			t.Errorf("Port Width conversion Error expected %d actual %d", util.Power(2, i), conv)
		} else {
			t.Logf("PASS expected %d actual %d", util.Power(2, i), conv)
		}
	}

	// Dimension 3, width 2,4,8
	p.Type = "bit[1:0][3:0][7:0]"
	portWidth = PortTypeToWidth(p)
	if len(portWidth) != 3 {
		t.Errorf("Port Width conversion Error")
	}
	for i, conv := range portWidth {
		if conv != util.Power(2, i+1) {
			t.Errorf("Port Width conversion Error expected %d actual %d", util.Power(2, i), conv)
		} else {
			t.Logf("PASS expected %d actual %d", util.Power(2, i+1), conv)
		}
	}

}
