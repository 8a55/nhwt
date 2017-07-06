//- untWounds ----------------------------------------------------------------
// ??
// maniac

unit untWounds;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses untTItem;
type

  TItem_Wound=class(TItem)
{   procedure Equip;override;
   function GetDefaultSlot:string;override;
   function GetCurrentSlotCompat(AItem:TItem):integer;override;}
  end;
  TItem_Wound_Serious=class(TItem)//серьёзное ранение.
  end;
  TItem_Wound_Fracture=class(TItem_Wound_Serious)
  end;
  TItem_Wound_Firearm=class(TItem_Wound_Serious)
  end;
  TItem_Wound_Bruise=class(TItem_Wound)
  end;
implementation
uses untSerialize;
//тыр
begin;
  AddSerialClass(TItem_Wound);
  AddSerialClass(TItem_Wound_Fracture);
  AddSerialClass(TItem_Wound_Firearm);
  AddSerialClass(TItem_Wound_Bruise);
end.
