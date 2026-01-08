codeunit 50122 "GeneralManagement"
{
    procedure UpdateProdOrderWarehouseData(var ProdOrder: Record "Production Order")
    var
        ProdLine: Record "Prod. Order Line";
        LastRL: Record "Prod. Order Routing Line";
        NewLoc, NewBin : Code[10];
    begin
        if not IsFeatureEnabled() then
            exit;

        ProdLine.SetRange(Status, ProdOrder.Status);
        ProdLine.SetRange("Prod. Order No.", ProdOrder."No.");
        if not ProdLine.FindSet() then
            exit;

        repeat
            // 1) Letzten Arbeitsgang für diese FA-Zeile ermitteln
            Clear(LastRL);
            if GetLastOperationForPOLine(ProdLine, LastRL) then begin
                // 2) Ziel-Lagerdaten aus WC/MC ziehen
                GetWCOrMCWarehouseDataForRouting(LastRL, NewLoc, NewBin);

                // 3) FA-Zeile aktualisieren (nur wenn Änderung, ohne Trigger)
                UpdateProdLine(ProdLine, NewLoc, NewBin);
            end;

            UpdateRoutingLinesForProdLine(ProdLine);

            UpdateComponentsForProdLine(ProdLine);

        until ProdLine.Next() = 0;
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        MfgSetup: Record "Manufacturing Setup";
    begin
        exit(MfgSetup.Get() and MfgSetup."Location from Prod. Routing");
    end;

    local procedure GetLastOperationForPOLine(ProdLine: Record "Prod. Order Line"; var LastRL: Record "Prod. Order Routing Line"): Boolean
    var
        RoutingLine: Record "Prod. Order Routing Line";
    begin
        RoutingLine.Reset();
        RoutingLine.SetRange(Status, ProdLine.Status);
        RoutingLine.SetRange("Prod. Order No.", ProdLine."Prod. Order No.");
        RoutingLine.SetRange("Routing Reference No.", ProdLine."Line No.");
        RoutingLine.SetCurrentKey("Prod. Order No.", "Routing Reference No.", "Operation No.");
        if RoutingLine.FindLast() then begin
            LastRL := RoutingLine;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetWCOrMCWarehouseDataForRouting(RoutingLine: Record "Prod. Order Routing Line"; var NewLoc: Code[10]; var NewBin: Code[10])
    var
        WC: Record "Work Center";
        MC: Record "Machine Center";
    begin
        Clear(NewLoc);
        Clear(NewBin);
        case RoutingLine.Type of
            RoutingLine.Type::"Work Center":
                if WC.Get(RoutingLine."No.") then begin
                    NewLoc := WC."Location Code";
                    NewBin := WC."From-Production Bin Code";
                end;
            RoutingLine.Type::"Machine Center":
                if MC.Get(RoutingLine."No.") then begin
                    NewLoc := MC."Location Code";
                    NewBin := MC."From-Production Bin Code";
                end;
        end;
    end;

    local procedure UpdateProdLine(var ProdLine: Record "Prod. Order Line"; NewLoc: Code[10]; NewBin: Code[10])
    var
        Changed: Boolean;
    begin
        Changed := false;

        if (NewLoc <> '') and (ProdLine."Location Code" <> NewLoc) then begin
            ProdLine."Location Code" := NewLoc;
            Changed := true;
        end;

        if (NewBin <> '') and (ProdLine."Bin Code" <> NewBin) then begin
            ProdLine."Bin Code" := NewBin;
            Changed := true;
        end;

        if Changed then
            ProdLine.Modify();
    end;

    procedure UpdateRoutingLinesForProdLine(ProdLine: Record "Prod. Order Line")
    var
        RoutingLine: Record "Prod. Order Routing Line";
        HasMatch: Boolean;
        NewLoc, NewBinTo, NewBinFrom, NewBinOpen : Code[10];
        CapacityType: Enum "Capacity Type";
        WC: Record "Work Center";
        MC: Record "Machine Center";
    begin
        RoutingLine.Reset();
        RoutingLine.SetRange(Status, ProdLine.Status);
        RoutingLine.SetRange("Prod. Order No.", ProdLine."Prod. Order No.");
        RoutingLine.SetRange("Routing Reference No.", ProdLine."Line No.");
        if not RoutingLine.FindFirst() then
            exit;
        repeat
            case RoutingLine.Type of
                CapacityType::"Work Center":
                    if WC.Get(RoutingLine."No.") then begin
                        if RoutingLine."Location Code" <> WC."Location Code" then
                            RoutingLine.Validate("Location Code", WC."Location Code");
                        if RoutingLine."Open Shop Floor Bin Code" <> WC."Open Shop Floor Bin Code" then
                            RoutingLine.Validate("Open Shop Floor Bin Code", WC."Open Shop Floor Bin Code");
                        if RoutingLine."To-Production Bin Code" <> WC."To-Production Bin Code" then
                            RoutingLine.Validate("To-Production Bin Code", WC."To-Production Bin Code");
                        if RoutingLine."From-Production Bin Code" <> WC."From-Production Bin Code" then
                            RoutingLine.Validate("From-Production Bin Code", WC."From-Production Bin Code");
                    end;
                CapacityType::"Machine Center":
                    if MC.Get(RoutingLine."No.") then begin
                        if RoutingLine."Location Code" <> MC."Location Code" then
                            RoutingLine.Validate("Location Code", MC."Location Code");
                        if RoutingLine."Open Shop Floor Bin Code" <> MC."Open Shop Floor Bin Code" then
                            RoutingLine.Validate("Open Shop Floor Bin Code", MC."Open Shop Floor Bin Code");
                        if RoutingLine."To-Production Bin Code" <> MC."To-Production Bin Code" then
                            RoutingLine.Validate("To-Production Bin Code", MC."To-Production Bin Code");
                        if RoutingLine."From-Production Bin Code" <> MC."From-Production Bin Code" then
                            RoutingLine.Validate("From-Production Bin Code", MC."From-Production Bin Code");
                    end;
            end;
            RoutingLine.Modify();

        until (RoutingLine.Next() = 0)

    end;

    // Komponenten der FA-Zeile aktualisieren
    // Logik:
    //   - Wenn Routing Link Code vorhanden → passende Routing Line suchen
    //   - sonst Fallback: erste Routing Line der FA-Zeile
    //   - Komp.Location = RL.Location
    //   - Komp.Bin = RL.To-Production Bin Code
    procedure UpdateComponentsForProdLine(ProdLine: Record "Prod. Order Line")
    var
        Comp: Record "Prod. Order Component";
        RoutingLine: Record "Prod. Order Routing Line";
        HasMatch: Boolean;
        NewLoc, NewBin : Code[10];
        Changed: Boolean;
    begin
        Comp.Reset();
        Comp.SetRange(Status, ProdLine.Status);
        Comp.SetRange("Prod. Order No.", ProdLine."Prod. Order No.");
        Comp.SetRange("Prod. Order Line No.", ProdLine."Line No.");

        if not Comp.FindSet() then
            exit;

        repeat
            // 1) Routing Line passend zur Komponente ermitteln
            Clear(RoutingLine);
            HasMatch := false;

            if Comp."Routing Link Code" <> '' then begin
                RoutingLine.Reset();
                RoutingLine.SetRange(Status, Comp.Status);
                RoutingLine.SetRange("Prod. Order No.", Comp."Prod. Order No.");
                RoutingLine.SetRange("Routing Reference No.", Comp."Prod. Order Line No.");
                RoutingLine.SetRange("Routing Link Code", Comp."Routing Link Code");
                HasMatch := RoutingLine.FindLast();
            end;

            if not HasMatch then begin
                RoutingLine.Reset();
                RoutingLine.SetRange(Status, Comp.Status);
                RoutingLine.SetRange("Prod. Order No.", Comp."Prod. Order No.");
                RoutingLine.SetRange("Routing Reference No.", Comp."Prod. Order Line No.");
                HasMatch := RoutingLine.FindFirst(); // Fallback: erste Routing-Zeile
            end;

            if HasMatch then begin
                NewLoc := RoutingLine."Location Code";
                NewBin := RoutingLine."To-Production Bin Code";
                Changed := false;

                if (NewLoc <> '') and (Comp."Location Code" <> NewLoc) then begin
                    Comp."Location Code" := NewLoc;
                    Changed := true;
                end;

                if (NewBin <> '') and (Comp."Bin Code" <> NewBin) then begin
                    Comp."Bin Code" := NewBin;
                    Changed := true;
                end;

                if Changed then
                    Comp.Modify();
            end;

        until Comp.Next() = 0;
    end;
}
