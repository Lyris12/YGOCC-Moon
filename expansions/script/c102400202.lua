--created & coded by Lyris
--フェイツ儀式術
local cid,id=GetID()
function cid.initial_effect(c)
	local getRitLevel=Card.GetRitualLevel
	Card.GetRitualLevel=function(tc,rc)
		if tc:IsLocation(LOCATION_SZONE) then
			local lv,t=tc:GetOriginalLevel(),{tc:IsHasEffect(EFFECT_RITUAL_LEVEL)}
			if #t>0 then lv=t[#t]:GetValue()(t[#t],rc) end
			return lv
		else return getRitLevel(tc,rc) end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.RitualUltimateTarget)
	e1:SetOperation(cid.RitualUltimateOperation)
	c:RegisterEffect(e1)
end
function cid.matfilter(c)
	return c:GetOriginalLevel()>0
end
function cid.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,gc)
	local trap=c:IsLocation(LOCATION_SZONE)
	if (not trap and c:GetType()&0x81~=0x81) or (filter and not filter(c,e,tp)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,trap,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	if gc then
		if not mg:IsContains(gc) then return false end
		Duel.SetSelectedCard(gc)
	end
	local lv=level_function(c)
	if trap then lv=c:GetOriginalLevel() end
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function cid.RitualUltimateTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local exg=Duel.GetMatchingGroup(cid.matfilter,tp,LOCATION_SZONE,0,nil)
		return Duel.IsExistingMatchingCard(cid.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),e,tp,mg,exg,Card.GetLevel,"Greater")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_SZONE)
end
function cid.RitualUltimateOperation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local exg=Duel.GetMatchingGroup(cid.matfilter,tp,LOCATION_SZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,cid.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),e,tp,mg,exg,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		local trap=tc:IsLocation(LOCATION_SZONE)
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if exg then
			mg:Merge(exg)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=tc:GetLevel()
		if trap then lv=tc:GetOriginalLevel() end
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,lv,"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,tc,lv,"Greater")
		aux.GCheckAdditional=nil
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,trap,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
