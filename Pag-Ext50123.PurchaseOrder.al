pageextension 50123 "Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Exclude from Planning"; Rec."Exclude from Planning")
            {
                ApplicationArea = All;

            }
        }
    }
}
