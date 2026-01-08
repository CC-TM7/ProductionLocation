pageextension 50122 "Firm Planned Prod. Order" extends "Firm Planned Prod. Order"
{
    actions
    {
        addafter("Re&fresh Production Order")
        {
            action("Get Location from Prod. Routing")
            {
                ApplicationArea = All;
                Image = RefreshLines;
                Caption = 'Lagerorte und -plätze aktualisieren';
                ToolTip = 'Aktualisiert auf Basis des Arbeitsplanes die Lagerorte und - plätze in den FA-Zeilen und deren Komponenten.';
                Promoted = true;
                PromotedCategory = Process;
                Visible = VisibleAction;
                trigger OnAction()
                var
                    GeneralMgmt: Codeunit GeneralManagement;
                begin
                    GeneralMgmt.UpdateProdOrderWarehouseData(Rec);
                end;
            }

        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "Manufacturing Setup";
    begin
        If Setup.Get() then
            VisibleAction := Setup."Location from Prod. Routing";
    end;

    var
        VisibleAction: Boolean;
}


//TODO Selbe Funktion auf der page 99000831 "Released Production Order"
