--Bigbang Origin
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 3 monsters with different Vibes (1 from your hand, 1 face-up on the field, and 1 from your Deck), and if you do, 
	--Special Summon 1 Level 10 or lower "Bigbang" Bigbang monster from your Extra Deck whose ATK and DEF are lower than or equal to the combined ATK of the destroyed non-Neutral monsters. (This is treated as a Bigbang Summon.)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_BIGBANG)
end
function s.filter(c,e,tp,atk,def)
	return c:IsType(TYPE_BIGBANG) and c:IsSetCard(0xbba) and c:IsAttackBelow(atk) and c:IsDefenseBelow(def) and c:IsLevelBelow(10)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.desfilter(c)
	return c:HasVibe()
end
function s.vselect(g,e,tp)
	local atk=0
	local def=0
	for tc in aux.Next(g) do
		if not tc:IsNeutral() then
		atk=atk+tc:GetAttack()
		def=def+tc:GetDefense()
		end
	end
	return g:GetClassCount(Card.GetVibe)==#g and g:GetClassCount(Card.GetLocation)==#g and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,atk,def)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,LOCATION_MZONE,nil)
	if chk==0 then return g:CheckSubGroup(s.vselect,3,3,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,LOCATION_MZONE,nil)
	if g:CheckSubGroup(s.vselect,3,3,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:SelectSubGroup(tp,s.vselect,false,3,3,e,tp)
		local atk=0
		local def=0
		for tc in aux.Next(sg) do
			if not tc:IsNeutral() then
				atk=atk+tc:GetAttack()
				def=def+tc:GetDefense()
			end
		end
		if Duel.Destroy(sg,REASON_EFFECT)>=3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,atk,def)
			local tc=g:GetFirst()
			if not tc then return end
			tc:SetMaterial(nil)
			Duel.SpecialSummon(tc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_BIGBANG)
end
