--Coded Land: Future City
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--maintain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0xded) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,1190) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1ded) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x2ded) and not c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.addfilter(c,lv)
	return c:IsSetCard(0x1ded) and not c:IsLevel(lv) and c:IsAbleToHand()
end
function s.tgfilter(c,e,tp)
	if not c:IsFaceup() or not c:IsSetCard(0xded) or c:IsAttack(c:GetBaseAttack()) then return false end
	local a=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetLevel())
	local b=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
	return a or b
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end --take a look for rulings at a later date
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return false end
	local a=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetLevel())
	local b=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil,tc:GetLevel())
	if a and b then
		e:SetLabel(Duel.SelectOption(tp,1075,1190))
	elseif a then
		e:SetLabel(Duel.SelectOption(tp,1075))
	elseif b then
		e:SetLabel(Duel.SelectOption(tp,1190)+1)
	else
		error("the hell?")
	end
	if e:GetLabel()==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
	end
end
