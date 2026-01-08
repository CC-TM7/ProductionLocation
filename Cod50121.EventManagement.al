codeunit 50121 EventManagement
{
    [EventSubscriber(ObjectType::Report, Report::"Refresh Production Order", 'OnAfterRefreshProdOrder', '', true, true)]
    local procedure OnAfterRefreshProdOrder(var ProductionOrder: Record "Production Order"; ErrorOccured: Boolean)
    begin
        GeneralMmgt.UpdateProdOrderWarehouseData(ProductionOrder);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", 'OnAfterValidateEvent', 'Routing Link Code', true, true)]
    local procedure ProdOrderComp_OnAfterValidate_RoutingLinkCode(var Rec: Record "Prod. Order Component"; var xRec: Record "Prod. Order Component"; CurrFieldNo: Integer)
    var
        ProdLine: Record "Prod. Order Line";
    begin
        if not GeneralMmgt.IsFeatureEnabled() then
            exit;

        ProdLine.Reset();
        if ProdLine.Get(Rec.Status, Rec."Prod. Order No.", Rec."Prod. Order Line No.") then
            GeneralMmgt.UpdateComponentsForProdLine(ProdLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterValidateEvent', 'Routing Link Code', true, true)]
    local procedure ProdOrderRoutingLine_OnAfterValidate_RoutingLinkCode(var Rec: Record "Prod. Order Routing Line"; var xRec: Record "Prod. Order Routing Line"; CurrFieldNo: Integer)
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.Reset();
        if ProdOrder.Get(Rec.Status, Rec."Prod. Order No.") then
            GeneralMmgt.UpdateProdOrderWarehouseData(ProdOrder);
    end;

    var
        GeneralMmgt: Codeunit GeneralManagement;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase Line Invt. Profile", 'OnBeforeCheckInsertPurchLineToProfile', '', false, false)]
    local procedure PurchLineInvtProfile_OnBeforeCheckInsertPurchLineToProfile(
    var InventoryProfile: Record "Inventory Profile";
    var PurchLine: Record "Purchase Line";
    ToDate: Date;
    var IsHandled: Boolean)
    begin
        //Bestellzeile soll NICHT im Planning-Supply auftauchen
        if PurchLine."Exclude from Planning" then begin
            IsHandled := true; // -> InventoryProfile wird nicht inseriert
        end;
    end;

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Inventory Profile Offsetting",
        'OnBeforeTransShptTransLineToProfile',
        '', false, false)]
    local procedure InvProfOffsetting_OnBeforeTransShptTransLineToProfile(
        var InventoryProfile: Record "Inventory Profile";
        var Item: Record Item;
        LineNo: Integer;
        var IsHandled: Boolean;
        var TransferLine: Record "Transfer Line")
    begin
        // Beispiel: Umlagerungszeile komplett aus der Planung rausnehmen
        //if TransferLine."Exclude from Planning" then begin
        //  IsHandled := true; // -> kein InventoryProfile für diese TransLine
        //end;
    end;

    [EventSubscriber(
    ObjectType::Codeunit,
    Codeunit::"Inventory Profile Offsetting",
    'OnTransShptTransLineToProfileOnBeforeProcessLine',
    '', false, false)]
    local procedure InvtProfile_OnTransShptTransLineToProfileOnBeforeProcessLine(
    TransferLine: Record "Transfer Line";
    var ShouldProcess: Boolean;
    var Item: Record Item)
    begin
        if TransferLine."Exclude from Planning" then
            ShouldProcess := false; // Transfer-Supply gar nicht erst ins Inventory Profile übernehmen
    end;


    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Inventory Profile Offsetting",
        'OnTransRcptTransLineToProfileOnBeforeProcessLine',
        '', false, false)]
    local procedure InvtProfile_OnTransRcptTransLineToProfileOnBeforeProcessLine(
        TransferLine: Record "Transfer Line";
        var ShouldProcess: Boolean;
        var Item: Record Item)
    var
        DiffDays: Decimal;
        Dat1: Date;
        Dat2: Date;
    begin
        if TransferLine."Exclude from Planning" then
            ShouldProcess := false;
    end;
}