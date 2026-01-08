pageextension 50121 "Manufacturing Setup" extends "Manufacturing Setup"
{
    layout
    {
        addlast(General)
        {
            field("Lagerdaten aus Arbeitsplan"; Rec."Location from Prod. Routing")
            {
                ApplicationArea = All;
                Caption = 'Lagerdaten aus Arbeitsplan';
                ToolTip = 'Wenn aktiviert, werden Lager-/Bin-Daten aus dem Arbeitsplan (Arbeitsplatzgruppe / Maschine) beim Aktualisieren des FAs in FA-Zeilen, Arbeitsplanzeilen und Komponenten gepflegt.';
            }
        }
    }
}
