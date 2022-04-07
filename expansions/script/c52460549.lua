--created by Meedogh, coded by Lyris & Raw
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(function() e1:SetLabel(1) return true end)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsDestructable() and c:IsSetCard(0xcf11) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,c,c,e,tp)
end
function s.filter(c,mc,e,tp)
	return c:IsType(TYPE_BIGBANG) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false)
		and aux.IsCodeListed(c,mc:GetOriginalCode()) and (c:IsFacedown()
		or not c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)) and mc:IsCanBeBigbangMaterial(c)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local l=e:GetLabel()==1
	if chk==0 then e:SetLabel(0) return l and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
	e:SetLabelObject(g)
	Duel.Destroy(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabelObject(),e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_BIGBANG,tp,tp,false,false,POS_FACEUP)>0 then tc:CompleteProcedure() end
end
