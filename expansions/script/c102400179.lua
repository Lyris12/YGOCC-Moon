--created & coded by Lyris
--フェイツ儀式術
local cid,id=GetID()
function cid.initial_effect(c)
	local f=Card.GetRitualLevel
	Card.GetRitualLevel=function(c,rc)
		if c:IsLocation(LOCATION_SZONE) then return c:GetOriginalLevel()+f(c,rc)&0xf0000 end
		return f(c,rc)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.RitualUltimateFilter(c,e,tp,m1,m2)
	local trap=c:IsType(TYPE_TRAP)
	if (not trap and c:GetType()&0x81~=0x81) or not c:IsSetCard(0xf7a) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,trap,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=trap and c:GetOriginalLevel() or c:GetLevel()
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,"Greater")
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,"Greater")
	aux.GCheckAdditional=nil
	return res
end
function cid.gfilter(c)
	return c:IsSetCard(0xf7a) and c:GetOriginalLevel()>0
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0xf7a)
		local exg=Duel.GetMatchingGroup(cid.gfilter,tp,LOCATION_SZONE,0,nil)
		return Duel.IsExistingMatchingCard(cid.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,e,tp,mg,exg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_SZONE)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0xf7a)
	local exg=Duel.GetMatchingGroup(cid.gfilter,tp,LOCATION_SZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,e,tp,mg,exg)
	local tc=tg:GetFirst()
	if tc then
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
		local trap=tc:IsType(TYPE_TRAP)
		local lv=trap and tc:GetOriginalLevel() or tc:GetLevel()
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,lv,"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,tc,lv,"Greater")
		aux.GCheckAdditional=nil
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		if trap then Duel.ConfirmCards(1-tp,tc) end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetValue(TYPE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,trap,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
