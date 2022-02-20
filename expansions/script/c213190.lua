--Code Portal - I.
function c213190.initial_effect(c)
	aux.AddCodeList(c,213200)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2,c213190.lcheck)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(213190,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,213190)
	e1:SetTarget(c213190.seqtg)
	e1:SetOperation(c213190.seqop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(213190,2))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,213191)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(c213190.discon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c213190.distg)
	e2:SetOperation(c213190.disop)
	c:RegisterEffect(e2)
end
function c213190.lcheck(g)
	return g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
function c213190.spfilter(c,e,tp)
	return (c:IsCode(213200) or aux.IsCodeListed(c,213200) and not c:IsCode(213190)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c213190.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
		return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
	end
end
function c213190.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	local s=zone
	if s&(s-1)~=0 then
		local flag=bit.bxor(zone,0xff)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
	end
	local nseq=math.log(s,2)
	Duel.MoveSequence(c,nseq)
	if c:GetSequence()==nseq then
       	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c213190.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(213190,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c213190.cfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(213200)
end
function c213190.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c213190.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c213190.nfilter(c)
	return aux.NegateAnyFilter(c) and c:IsFaceup() and c:IsType(TYPE_TRAP)
end
function c213190.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c213190.nfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c213190.nfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,c213190.nfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c213190.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end