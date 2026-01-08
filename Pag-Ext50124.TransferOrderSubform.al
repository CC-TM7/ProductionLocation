pageextension 50124 "Transfer Order Subform" extends "Transfer Order Subform"
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
