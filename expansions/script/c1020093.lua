--C.VIATRIX: Impulso
--Script by XGlitchy30
function c1020093.initial_effect(c)
	--link procedure
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),1)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020093,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1020093)
	e1:SetCondition(c1020093.negcon)
	e1:SetTarget(c1020093.negtg)
	e1:SetOperation(c1020093.negop)
	c:RegisterEffect(e1)
	--spsummon GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020093,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1120093)
	e2:SetCost(c1020093.spcost)
	e2:SetTarget(c1020093.sptg)
	e2:SetOperation(c1020093.spop)
	c:RegisterEffect(e2)
end
--filters
function c1020093.negfilter(c,g)
	return aux.disfilter1(c) and g:IsContains(c)
end
function c1020093.disfilter(c,e)
	return ((c:IsFaceup() and not c:IsDisabled()) or c:IsType(TYPE_TRAPMONSTER)) and c:IsRelateToEffect(e)
end
function c1020093.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x39c) and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(c1020093.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.GetMZoneCount(tp,c)>0
end
function c1020093.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--negate
function c1020093.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c1020093.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsOnField() and c1020093.negfilter(chkc,lg) end
	if chk==0 then return Duel.IsExistingTarget(c1020093.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil,lg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c1020093.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil,lg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
function c1020093.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c1020093.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		c:SetCardTarget(tc)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c1020093.effectcon)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetCondition(c1020093.effectcon)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetCondition(c1020093.effectcon)
			e3:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
function c1020093.effectcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
--spsummon GY
function c1020093.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c1020093.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,c1020093.cfilter,1,e:GetHandler(),e,tp) 
	end
	e:SetLabel(0)
	local g=Duel.SelectReleaseGroup(tp,c1020093.cfilter,1,1,e:GetHandler(),e,tp)
	Duel.Release(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c1020093.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1020093.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end