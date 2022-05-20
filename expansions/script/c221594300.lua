--created by Walrus, coded by Lyris
--Voidictator Energy - Origin Essence
local s,id,o=GetID()
function s.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetDescription(1164)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetCost(s.cost)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	if not c:IsSetCard(0xc97) or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_HAND) then return c:IsDiscardable(REASON_EFFECT)
	else return c:IsAbleToRemove() end
end
function s.spfilter(c,e,tp,t)
	if not c:IsSetCard(0x6c97) then return false end
	if not t then t={
		[TYPE_FUSION]=SUMMON_TYPE_FUSION,
		[TYPE_SYNCHRO]=SUMMON_TYPE_SYNCHRO,
		[TYPE_BIGBANG]=SUMMON_TYPE_BIGBANG,
		[TYPE_EVOLUTE]=SUMMON_TYPE_EVOLUTE,
	} end
	local st=t[c:GetType()&TYPE_EXTRA]
	return st~=nil and c:IsCanBeSpecialSummoned(e,st,tp,false,false)
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable(REASON_EFFECT) and Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,c)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	if not c:IsRelateToEffect(e) or #mg<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local g=mg:Select(tp,2,2,nil)+c
	local t={
		[TYPE_FUSION]=SUMMON_TYPE_FUSION,
		[TYPE_SYNCHRO]=SUMMON_TYPE_SYNCHRO,
		[TYPE_BIGBANG]=SUMMON_TYPE_BIGBANG,
		[TYPE_EVOLUTE]=SUMMON_TYPE_EVOLUTE,
	}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,t):GetFirst()
	if sc then
		sc:SetMaterial(g)
		Duel.Remove(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT)
		Duel.SendtoGrave(g:Filter(Card.IsLocation,nil,LOCATION_HAND),REASON_EFFECT+REASON_DISCARD)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,t[sc:GetType()&TYPE_EXTRA],tp,tp,false,false,POS_FACEUP)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
