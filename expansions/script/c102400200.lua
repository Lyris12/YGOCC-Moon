--created & coded by Lyris
--フェイツ・アセンション
local cid,id=GetID()
function cid.initial_effect(c)
	local f=Card.GetRitualLevel
	Card.GetRitualLevel=function(c,rc)
		if c:IsLocation(LOCATION_SZONE) then return c:GetOriginalLevel()+f(c,rc)&0xf0000 end
		return f(c,rc)
	end
	local e1=aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),e,tp,Duel.GetRitualMaterial(tp),Duel.GetMatchingGroup(function(tc) return tc:GetOriginalLevel()>0 end,tp,LOCATION_SZONE,0,nil),Card.GetLevel,"Greater",true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local exg=Duel.GetMatchingGroup(function(tc) return tc:GetOriginalLevel()>0 end,tp,LOCATION_SZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),e,tp,mg,exg,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)+exg
		if tc.mat_filter then mg=mg:Filter(tc.mat_filter,tc,tp)
		else mg:RemoveCard(tc) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=tc:GetLevel()
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,lv,"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,false,1,lv,tp,tc,lv,"Greater")
		aux.GCheckAdditional=nil
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetValue(TYPE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
