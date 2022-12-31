--VECTOR Engineer Narja
--Scripted by Keddy, reworked by Zerry
function c67864649.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,c67864649.lmfilter,2,2)
	c:EnableReviveLimit()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67864649,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,67864649)
	e1:SetCondition(c67864649.spcon)
	e1:SetCost(c67864649.spcost)
	e1:SetTarget(c67864649.sptg)
	e1:SetOperation(c67864649.spop)
	c:RegisterEffect(e1)
end
function c67864649.lmfilter(c)
	return c:IsLinkSetCard(0x2a6)
end
function c67864649.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetMaterial():IsExists(c67864649.stunfilter,1,nil)
end
function c67864649.stunfilter(c)
	return c:IsSetCard(0x62a6) and c:IsLevelBelow(4)
end
function c67864649.cfilter(c)
	return c:IsDiscardable()
end
function c67864649.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864649.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c67864649.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
function c67864649.spfilter(c,e,tp)
	return c:IsSetCard(0x2a6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(6)
end
function c67864649.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864649.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function c67864649.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c67864649.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c67864649.splimit)
		Duel.RegisterEffect(e1,tp)
	end
end
function c67864649.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x2a6)
end