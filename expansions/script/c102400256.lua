--created & coded by Lyris, art from Cardfight!! Vanguard's "Kelpie Rider, Nikki"
--アーマリン・シーホース・ライダー
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT>0 end)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e5:SetTarget(s.tg)
	e5:SetOperation(s.op)
	c:RegisterEffect(e5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a then return false end
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	return a~=e:GetHandler() and a:IsRelateToBattle() and a:IsSetCard(0xa6c)
		and Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated()
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xa6c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function s.tdfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsAbleToDeck()
end
function s.check(g,sc,e,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xa6c) and g:CheckWithSumEqual(Card.GetLevel,sc:GetLevel(),#g,#g)
end
function s.sfilter(c,e,tp,g)
	return c:IsSetCard(0xa6c) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and g:CheckSubGroup(s.check,1,99,c,e,tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
		return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)>0 and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)<=0 or #mg==0 or #sg==0 then return end
	local dg,sc
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sc=sg:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		dg=mg:SelectSubGroup(tp,s.check,true,1,99,sc,e,tp)
	until dg~=nil
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
end
