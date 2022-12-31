--Mekbuster Peacekeeper IL9-Y2
function c67864650.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(67864650)
	--link summon
	aux.AddLinkProcedure(c,c67864650.matfilter,2)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67864650,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c67864650.thcon)
	e1:SetTarget(c67864650.thtg)
	e1:SetOperation(c67864650.thop)
	c:RegisterEffect(e1)
	--Lvl change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67864650,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetTarget(c67864650.target)
	e2:SetOperation(c67864650.operation)
	c:RegisterEffect(e2)
end
function c67864650.matfilter(c)
	return c:IsSetCard(0x2a6)
end
function c67864650.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c67864650.thfilter(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() 
end
function c67864650.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864650.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c67864650.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c67864650.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c67864650.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a6) and c:IsLevelAbove(1)
end
function c67864650.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67864650.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c67864650.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c67864650.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local op=0
	if tc:IsLevel(1) then op=Duel.SelectOption(tp,aux.Stringid(67864650,2))
	else op=Duel.SelectOption(tp,aux.Stringid(67864650,2),aux.Stringid(67864650,3)) end
	e:SetLabel(op)
end
function c67864650.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else e1:SetValue(-1) end
		tc:RegisterEffect(e1)
	end
end