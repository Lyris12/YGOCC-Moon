--Welch, the Cascad Vanguard
--Script by XGlitchy30
function c31231316.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),6,2)
	c:EnableReviveLimit()
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31231316,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c31231316.negcon)
	e1:SetOperation(c31231316.negop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c31231316.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--banish deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31231316,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31231316)
	e3:SetCost(c31231316.rmcost)
	e3:SetTarget(c31231316.rmtg)
	e3:SetOperation(c31231316.rmop)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31231316,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,31231216)
	e4:SetCost(c31231316.hspcost)
	e4:SetTarget(c31231316.hsptg)
	e4:SetOperation(c31231316.hspop)
	c:RegisterEffect(e4)
end
--filters
function c31231316.negfilter(c)
	return c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:IsType(TYPE_EFFECT))
end
function c31231316.matfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x3233)
end
function c31231316.rmcheck(c)
	return c:IsRace(RACE_AQUA) and c:IsAbleToRemoveAsCost() and (c:GetLevel()>0 or c:GetRank()>0)
end
function c31231316.rfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
--negate
function c31231316.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c31231316.matfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c31231316.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function c31231316.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c31231316.negfilter,tp,0,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
--banish deck
function c31231316.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) 
		and Duel.IsExistingMatchingCard(c31231316.rmcheck,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	local rem=Duel.SelectMatchingCard(tp,c31231316.rmcheck,tp,LOCATION_GRAVE,0,1,1,nil)
	if rem:GetCount()>0 then
		if Duel.Remove(rem:GetFirst(),POS_FACEUP,REASON_COST)~=0 then
			local og=Duel.GetOperatedGroup()
			local op=og:GetFirst()
			if op:IsType(TYPE_XYZ) then
				e:SetLabel(op:GetRank())
			else
				e:SetLabel(op:GetLevel())
			end
		else return false end
	end
end
function c31231316.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function c31231316.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct0=e:GetLabel()
	local ct1=ct0+2
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct1>ct2 then ct1=ct2 end
	if ct1==0 then return end
	local g=Duel.GetDecktopGroup(1-tp,ct1)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
--spsummon
function c31231316.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31231316.rfilter,tp,LOCATION_GRAVE,0,6,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c31231316.rfilter,tp,LOCATION_GRAVE,0,6,6,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c31231316.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31231316.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end