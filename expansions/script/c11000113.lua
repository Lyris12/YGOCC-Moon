--Disintegration
function c11000113.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c11000113.condition)
	e1:SetTarget(c11000113.target)
	e1:SetOperation(c11000113.activate)
	c:RegisterEffect(e1)
end
function c11000113.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function c11000113.dfilter(c)
	return c:IsAttackPos() and c:IsDestructable()
end
function c11000113.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1F4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function c11000113.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000113.dfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(c11000113.dfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c11000113.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c11000113.dfilter,tp,0,LOCATION_MZONE,nil)
	local st=Duel.Destroy(g,REASON_EFFECT)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if st==0 or ft<=0 then return end
	if ft>st then ft=st end
	local sg=Duel.GetMatchingGroup(c11000113.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(11000113,1))
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0  then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=sg:Select(tp,1,ft,nil)
		local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local lp=Duel.GetLP(tp)
		if lp<=ct*1500 then
		Duel.SetLP(tp,0)
		else
		Duel.SetLP(tp,lp-ct*1500)
		end
	end
end