--VECTOR Engineer Narja
--Scripted by Keddy, reworked by Zerry
function c67864649.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,c67864649.lmfilter,2,2)
	c:EnableReviveLimit()
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67864649,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,67864649)
	e3:SetCost(c67864649.cost)
	e3:SetCondition(c67864649.spcon)
	e3:SetTarget(c67864649.sptg)
	e3:SetOperation(c67864649.spop)
	c:RegisterEffect(e3)
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
function c67864642.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864642.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c67864642.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
function c67864649.spfilter(c,e,tp)
	return c:IsSetCard(0x62a6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(6)
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
			local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_FIELD)
				e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)	
				e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e4:SetReset(RESET_PHASE+PHASE_END)
				e4:SetTargetRange(1,0)
				e4:SetTarget(c67864649.splimit)
				Duel.RegisterEffect(e4,tp)
	end
end
function c67864649.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsSetCard(0x2a6) or (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)))
end	