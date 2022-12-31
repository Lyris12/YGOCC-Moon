--Mysterious Hyper Dragon
function c53313920.initial_effect(c)
	--Materials: 1 Tuner Synchro + 1+ non-Tuner "Mysterious" Pandemonium monsters
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(c53313920.sfilter),1)
	c:EnableReviveLimit()
	--Once per turn, during your Main Phase 1: You can banish up to 3 cards from your GY and/or face-up cards from your Extra Deck with different names; this card's maximum number of attacks this turn is equal to the number of "Mysterious" cards banished to activate this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(1115)
	e1:SetTarget(c53313920.atkcost)
	e1:SetOperation(c53313920.atkop)
	c:RegisterEffect(e1)
	--During your Main Phase: You can target 1 Level 7 or lower "Mysterious" monster you control, in your GY, or that is banished; until the end of this turn, this card gains that monster's original effects (if any). (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53313920)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(1103)
	e2:SetTarget(c53313920.target)
	e2:SetOperation(c53313920.operation)
	c:RegisterEffect(e2)
end
function c53313920.sfilter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsSetCard(0xcf6)
end
function c53313920.filter(c,ct)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and (c:IsSetCard(0xcf6) or ct>0)
end
function c53313920.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313920.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,LOCATION_EXTRA+LOCATION_GRAVE,1,nil,0) and Duel.GetCurrentPhase()==PHASE_MAIN1 end
	local rg=Duel.GetFieldGroup(tp,LOCATION_EXTRA+LOCATION_GRAVE,LOCATION_EXTRA+LOCATION_GRAVE)
	local g=Group.CreateGroup()
	local i=0
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=rg:FilterSelect(tp,c53313920.filter,1,1,nil,i):GetFirst()
		g=g+tc
		rg:Remove(Card.IsCode,nil,tc:GetCode())
		if tc:IsSetCard(0xcf6) then i=i+1 end
	until g:GetCount()>2 or rg:GetCount()==0 or not Duel.SelectYesNo(tp,aux.Stringid(30539496,3))
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	e:SetLabel(i)
end
function c53313920.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	end
end
function c53313920.copytg(c)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsLevelBelow(7) and c:IsSetCard(0xcf6)
end
function c53313920.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x34) and (chkc:IsControler(tp) or chkc:IsLocation(LOCATION_REMOVED)) and c53313920.copytg(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0x34,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0x34,LOCATION_REMOVED,1,1,nil)
end
function c53313920.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	end
end
